# frozen_string_literal: true

module ConcurrentRails::Adapters
  module Delay
    extend ActiveSupport::Concern

    class_methods do
      def delay(*args, &task)
        delay_on(:io, *args, &task)
      end

      def delay_on(executor, *args, &task)
        new(executor).delay_on_rails(*args, &task)
      end
    end

    def delay_on_rails(*args, &task)
      @instance = rails_wrapped { delay_on(executor, *args, &task) }

      self
    end

    delegate :touch, to: :instance
  end
end
