# frozen_string_literal: true

module ConcurrentRails
  module ScheduleAdapter
    extend ActiveSupport::Concern

    class_methods do
      def schedule(delay, *args, &task)
        schedule_on(:io, delay, *args, &task)
      end

      def schedule_on(executor, delay, *args, &task)
        new(executor, Concurrent::Promises.schedule_on(executor, delay, *args, &wrap_task(task)))
      end
    end
  end
end
