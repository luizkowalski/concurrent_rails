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
        new(executor).run_on_rails(*args, &task)
      end
    end

    def initialize(executor)
      @executor = executor
    end

    def run_on_rails(*args, &task)
      @future_instance = rails_wrapped { future_on(executor, *args, &task) }

      self
    end

    %i[then chain].each do |chainable|
      define_method(chainable) do |*args, &task|
        method = "#{chainable}_on"
        @future_instance = rails_wrapped do
          future_instance.__send__(method, executor, *args, &task)
        end

        self
      end
    end

    %i[value value!].each do |method_name|
      define_method(method_name) do |timeout = nil, timeout_value = nil|
        rails_wrapped do
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            future_instance.__send__(method_name, timeout, timeout_value)
          end
        end
      end
    end

    %i[state reason rejected? resolved? fulfilled?].each do |delegatable|
      def_delegator :@future_instance, delegatable
    end

    private

    def rails_wrapped(&block)
      Rails.application.executor.wrap(&block)
    end

    attr_reader :future_instance, :executor
  end
end
