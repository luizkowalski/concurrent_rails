# frozen_string_literal: true

module ConcurrentRails
  module FutureAdapter
    extend ActiveSupport::Concern

    class_methods do
      def future(*args, &task)
        future_on(:io, *args, &task)
      end

      def future_on(executor, *args, &task)
        new(executor).future_on_rails(*args, &task)
      end
    end

    def future_on_rails(*args, &task)
      @instance = rails_wrapped { future_on(executor, *args, &task) }

      self
    end
  end
end
