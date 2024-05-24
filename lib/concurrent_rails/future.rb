# frozen_string_literal: true

module ConcurrentRails
  class Future
    def initialize(executor: :io, &block)
      @executor = executor
      @future   = run_on_rails(block)
      ActiveSupport::Deprecation.warn("ConcurrentRails::Future is deprecated. See README for details")
    end

    def execute
      future.execute

      self
    end

    %i[value value!].each do |method_name|
      define_method method_name do
        permit_concurrent_loads do
          future.__send__(method_name)
        end
      end
    end

    delegate :state, :reason, :rejected?, :complete?, :add_observer, to: :future

    private

    def run_on_rails(block)
      @future = rails_wrapped do
        Concurrent::Future.new(executor:) do
          rails_wrapped(&block)
        end
      end
    end

    def rails_wrapped(&)
      Rails.application.executor.wrap(&)
    end

    def permit_concurrent_loads(&block)
      rails_wrapped do
        ActiveSupport::Dependencies.interlock.permit_concurrent_loads(&block)
      end
    end

    attr_reader :executor, :future
  end
end
