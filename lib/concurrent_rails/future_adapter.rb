# frozen_string_literal: true

module ConcurrentRails
  module FutureAdapter
    extend ActiveSupport::Concern

    class_methods do
      def future(*args, &task)
        future_on(:io, *args, &task)
      end

      def future_on(executor, *args, &task)
        new(executor, Concurrent::Promises.future_on(executor, *args, &wrap_task(task)))
      end
    end
  end
end
