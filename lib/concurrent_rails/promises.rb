# frozen_string_literal: true

module ConcurrentRails
  class Promises
    include ConcurrentRails::CombinatorAdapter
    include ConcurrentRails::DelayAdapter
    include ConcurrentRails::FutureAdapter
    include ConcurrentRails::ScheduleAdapter

    def self.wrap_task(task)
      proc { |*args| Rails.application.executor.wrap { task.call(*args) } }
    end
    private_class_method :wrap_task

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
        wrapped_task = self.class.__send__(:wrap_task, task)
        derived = instance.public_send(:"#{chainable}_on", executor, *args, &wrapped_task)

        self.class.new(executor, derived)
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
        wrapped_callback = self.class.__send__(:wrap_task, callback_task)
        instance.public_send(:"#{method}_using", executor, *args, &wrapped_callback)

        self
      end

      define_method(:"#{method}!") do |*args, &callback_task|
        wrapped_callback = self.class.__send__(:wrap_task, callback_task)
        instance.public_send(:"#{method}!", *args, &wrapped_callback)

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
