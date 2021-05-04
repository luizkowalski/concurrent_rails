# frozen_string_literal: true

module ConcurrentRails
  class Future
    extend Forwardable

    def initialize(executor: :fast, &block)
      @executor = executor
      @future   = run_on_rails(block)
    end

    def execute
      future.execute

      self
    end

    %i[value value!].each do |method_name|
      define_method method_name do
        rails_wrapped do
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            future.__send__(method_name)
          end
        end
      end
    end

    def_delegators :@future, :state, :reason, :rejected?, :complete?, :add_observer

    private

    def run_on_rails(block)
      @future = rails_wrapped do
        Concurrent::Future.new(executor: executor) do
          rails_wrapped(&block)
        end
      end
    end

    def rails_wrapped(&block)
      Rails.application.executor.wrap(&block)
    end

    attr_reader :executor, :future
  end
end
