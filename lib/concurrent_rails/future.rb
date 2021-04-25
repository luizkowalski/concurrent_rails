# frozen_string_literal: true

module ConcurrentRails
  class Future
    extend Forwardable

    def initialize(executor: :io, &block)
      @executor = executor
      @future   = run_on_rails(block)
    end

    def execute
      future.execute

      self
    end

    %i[value value!].each do |method_name|
      define_method method_name do
        Rails.application.executor.wrap do
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            future.__send__(method_name)
          end
        end
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

    attr_reader :executor, :future
  end
end
