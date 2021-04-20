# frozen_string_literal: true

module ConcurrentRails
  class Promises
    include Concurrent::Promises::FactoryMethods
    extend Forwardable

    def self.future(*args, &task)
      new.run_on_rails(*args, &task)
    end

    def then(*args, &task)
      @future_instance = Rails.application.executor.wrap do
        future_instance.then(*args, &task)
      end

      self
    end

    %i[value value!].each do |method_name|
      define_method method_name do
        Rails.application.executor.wrap do
          result = nil

          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            result = future_instance.__send__(method_name)
          end

          result
        end
      end
    end

    def run_on_rails(*args, &task)
      @future_instance = Rails.application.executor.wrap do
        future_on(default_executor, *args, &task)
      end

      self
    end

    def_delegators :@future_instance, :state, :reason, :rejected?, :complete?

    private

    attr_reader :future_instance
  end
end
