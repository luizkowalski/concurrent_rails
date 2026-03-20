# frozen_string_literal: true

module ConcurrentRails
  class Promises
    include Concurrent::Promises::FactoryMethods
    include ConcurrentRails::CombinatorAdapter
    include ConcurrentRails::DelayAdapter
    include ConcurrentRails::FutureAdapter
    include ConcurrentRails::ScheduleAdapter

    def initialize(executor)
      @executor = executor
    end

    %i[value value!].each do |method_name|
      define_method(method_name) do |timeout = nil, timeout_value = nil|
        with_concurrent_load do
          instance.public_send(method_name, timeout, timeout_value)
        end
      end
    end

    %i[then chain].each do |chainable|
      define_method(chainable) do |*args, &task|
        method = "#{chainable}_on"
        wrapped_task = proc { |*a| rails_wrapped { task.call(*a) } }
        @instance = instance.public_send(method, executor, *args, &wrapped_task)

        self
      end
    end

    def touch
      @instance = rails_wrapped { instance.touch }

      self
    end

    def wait(timeout = nil)
      result = with_concurrent_load { instance.__send__(:wait_until_resolved, timeout) }

      timeout ? result : self
    end

    %i[on_fulfillment on_rejection on_resolution].each do |method|
      define_method(method) do |*args, &callback_task|
        wrapped_callback = proc { |*a| rails_wrapped { callback_task.call(*a) } }
        @instance = instance.__send__(:"#{method}_using", executor, *args, &wrapped_callback)

        self
      end

      define_method(:"#{method}!") do |*args, &callback_task|
        wrapped_callback = proc { |*a| rails_wrapped { callback_task.call(*a) } }
        @instance = instance.__send__(:add_callback, "callback_#{method}", args, wrapped_callback)

        self
      end
    end

    delegate :state, :reason, :rejected?, :resolved?, :fulfilled?, to: :instance

    attr_reader :executor

    private

    def rails_wrapped(&)
      Rails.application.executor.wrap(&)
    end

    def with_concurrent_load(&block)
      rails_wrapped do
        ActiveSupport::Dependencies.interlock.permit_concurrent_loads(&block)
      end
    end

    attr_reader :instance
  end
end
