# frozen_string_literal: true

module ConcurrentRails
  module DelayAdapter
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
      wrapped_task = proc { |*a| rails_wrapped { task.call(*a) } }
      @instance = delay_on(executor, *args, &wrapped_task)

      self
    end
  end
end
