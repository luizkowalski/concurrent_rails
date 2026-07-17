# frozen_string_literal: true

module ConcurrentRails
  module DelayAdapter
    extend ActiveSupport::Concern

    class_methods do
      def delay(*args, &task)
        delay_on(:io, *args, &task)
      end

      def delay_on(executor, *args, &task)
        new(executor, Concurrent::Promises.delay_on(executor, *args, &wrap_task(task)))
      end
    end
  end
end
