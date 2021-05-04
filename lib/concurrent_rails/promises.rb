# frozen_string_literal: true

module ConcurrentRails
  class Promises
    extend Forwardable
    include Concurrent::Promises::FactoryMethods

    class << self
      def future(*args, &task)
        future_on(:fast, *args, &task)
      end

      def future_on(executor, *args, &task)
        new.with_rails(executor, *args, &task)
      end
    end

    def then(*args, &task)
      @future_instance = Rails.application.executor.wrap do
        future_instance.then(*args, &task)
      end

      self
    end

    def chain(*args, &task)
      Rails.application.executor.wrap do
        future_instance.chain(*args, &task)
      end

      self
    end

    %i[value value!].each do |method_name|
      define_method method_name do |timeout = nil, timeout_value = nil|
        Rails.application.executor.wrap do
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            future_instance.__send__(method_name, timeout, timeout_value)
          end
        end
      end
    end

    def with_rails(executor, *args, &task)
      @future_instance = Rails.application.executor.wrap do
        future_on(executor, *args, &task)
      end

      self
    end

    def_delegators :@future_instance, :state, :reason, :rejected?, :resolved?

    private

    attr_reader :future_instance
  end
end
