# frozen_string_literal: true

module ConcurrentRails
  module FutureAdapter
    extend ActiveSupport::Concern

    class_methods do
      def future(...)
        future_on(...)
      end

      def future_on(...)
        new(executor).future_on_rails(...)
      end
    end

    def future_on_rails(...)
      @instance = rails_wrapped { future_on(...) }

      self
    end
  end
end
