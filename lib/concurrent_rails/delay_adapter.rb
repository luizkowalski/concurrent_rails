# frozen_string_literal: true

module ConcurrentRails
  module DelayAdapter
    extend ActiveSupport::Concern

    class_methods do
      def delay(...)
        delay_on(...)
      end

      def delay_on(...)
        new(executor).delay_on_rails(...)
      end
    end

    def delay_on_rails(...)
      @instance = rails_wrapped { delay_on(...) }

      self
    end
  end
end
