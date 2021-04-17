# frozen_string_literal: true

module ConcurrentRails
  class Future
    extend Forwardable

    def initialize(executor: :io, &block)
      @task     = block
      @executor = executor
      @future   = run_on_rails(block)
    end

    def execute
      future.execute

      self
    end

    def value
      Rails.application.executor.wrap do
        result = nil

        ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
          result = future.value
        end

        result
      end
    end

    def_delegators :@future, :state, :reason, :rejected?, :complete?, :add_observer

    private

    def run_on_rails(block)
      @future = Rails.application.executor.wrap do
        Concurrent::Future.new(executor: executor) do
          Rails.application.executor.wrap(&block)
        end
      end
    end

    attr_reader :executor, :task, :future
  end
end
