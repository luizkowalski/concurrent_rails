# frozen_string_literal: true

module ConcurrentRails
  class Promises
    include Concurrent::Promises::FactoryMethods
    include ConcurrentRails::DelayAdapter
    include ConcurrentRails::FutureAdapter

    def initialize(executor)
      @executor = executor
    end

    %i[value value!].each do |method_name|
      define_method(method_name) do |timeout = nil, timeout_value = nil|
        permit_concurrent_loads do
          instance.public_send(method_name, timeout, timeout_value)
        end
      end
    end

    %i[then chain].each do |chainable|
      define_method(chainable) do |*args, &task|
        method = "#{chainable}_on"
        @instance = rails_wrapped do
          instance.public_send(method, executor, *args, &task)
        end

        self
      end
    end

    def touch
      @instance = rails_wrapped { instance.touch }

      self
    end

    def wait(timeout = nil)
      result = permit_concurrent_loads { instance.__send__(:wait_until_resolved, timeout) }

      timeout ? result : self
    end

    %i[on_fulfillment on_rejection on_resolution].each do |method|
      define_method(method) do |*args, &callback_task|
        rails_wrapped do
          @instance = instance.__send__(:"#{method}_using", executor, *args, &callback_task)
        end

        self
      end

      define_method(:"#{method}!") do |*args, &callback_task|
        rails_wrapped do
          @instance = instance.__send__(:add_callback, "callback_#{method}", args, callback_task)
        end

        self
      end
    end

    delegate :state, :reason, :rejected?, :resolved?, :fulfilled?, to: :instance

    attr_reader :executor

    private

    def rails_wrapped(&)
      Rails.application.executor.wrap(&)
    end

    def permit_concurrent_loads(&block)
      rails_wrapped do
        ActiveSupport::Dependencies.interlock.permit_concurrent_loads(&block)
      end
    end

    attr_reader :instance
  end
end
