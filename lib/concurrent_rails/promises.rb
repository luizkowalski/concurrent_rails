# frozen_string_literal: true

module ConcurrentRails
  class Promises
    class << self
      %i[future delay schedule].each do |factory|
        define_method(factory) do |*args, &task|
          public_send(:"#{factory}_on", :io, *args, &task)
        end

        define_method(:"#{factory}_on") do |executor, *args, &task|
          new(executor, Concurrent::Promises.public_send(:"#{factory}_on", executor, *args, &wrap_task(task)))
        end
      end

      def zip(*promises)
        new(:io, Concurrent::Promises.zip(*unwrap(promises)))
      end

      def any_resolved_future(*promises)
        new(:io, Concurrent::Promises.any_resolved_future(*unwrap(promises)))
      end

      def fulfilled_future(value, executor = :io)
        new(executor, Concurrent::Promises.fulfilled_future(value))
      end

      def rejected_future(reason, executor = :io)
        new(executor, Concurrent::Promises.rejected_future(reason))
      end

      def wrap_task(task)
        proc { |*args| Rails.application.executor.wrap { task.call(*args) } }
      end

      private

      def unwrap(promises)
        promises.map { |p| p.is_a?(Promises) ? p.__send__(:instance) : p }
      end
    end

    def initialize(executor, instance)
      @executor = executor
      @instance = instance
    end

    %i[value value!].each do |method_name|
      define_method(method_name) do |timeout = nil, timeout_value = nil|
        rails_wrapped { instance.public_send(method_name, timeout, timeout_value) }
      end
    end

    %i[then chain].each do |chainable|
      define_method(chainable) do |*args, &task|
        self.class.new(executor, instance.public_send(:"#{chainable}_on", executor, *args, &self.class.wrap_task(task)))
      end
    end

    def touch
      instance.touch

      self
    end

    def wait(timeout = nil)
      result = rails_wrapped { instance.wait(timeout) }

      timeout ? result : self
    end

    %i[on_fulfillment on_rejection on_resolution].each do |method|
      define_method(method) do |*args, &callback_task|
        instance.public_send(:"#{method}_using", executor, *args, &self.class.wrap_task(callback_task))

        self
      end

      define_method(:"#{method}!") do |*args, &callback_task|
        instance.public_send(:"#{method}!", *args, &self.class.wrap_task(callback_task))

        self
      end
    end

    delegate :state, :reason, :rejected?, :resolved?, :fulfilled?, to: :instance

    attr_reader :executor

    private

    def rails_wrapped(&)
      Rails.application.executor.wrap(&)
    end

    attr_reader :instance
  end
end
