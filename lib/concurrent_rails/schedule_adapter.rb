# frozen_string_literal: true

module ConcurrentRails
  module ScheduleAdapter
    extend ActiveSupport::Concern

    class_methods do
      def schedule(delay, *args, &task)
        schedule_on(:io, delay, *args, &task)
      end

      def schedule_on(executor, delay, *args, &task)
        new(executor).schedule_on_rails(delay, *args, &task)
      end
    end

    def schedule_on_rails(delay, *args)
      wrapped_task = proc { |*a| rails_wrapped { yield(*a) } }
      @instance = schedule_on(executor, delay, *args, &wrapped_task)

      self
    end
  end
end
