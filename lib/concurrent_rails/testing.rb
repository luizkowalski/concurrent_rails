# frozen_string_literal: true

module ConcurrentRails
  class Testing
    ISOLATION_KEY = :concurrent_rails_testing_mode

    class << self
      def execution_mode
        ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] || @default_mode || "real" # rubocop:disable ThreadSafety/ClassInstanceVariable
      end

      %w[immediate fake real].each do |test_mode|
        define_method(test_mode) do |&task|
          previous = ActiveSupport::IsolatedExecutionState[ISOLATION_KEY]
          ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] = test_mode

          task.call
        ensure
          ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] = previous
        end

        define_method(:"#{test_mode}!") do
          @default_mode = test_mode
        end

        define_method(:"#{test_mode}?") do
          execution_mode == test_mode
        end
      end
    end

    module TestingFuture
      %i[future delay].each do |factory|
        define_method(factory) do |*args, &task|
          if ConcurrentRails::Testing.immediate?
            public_send(:"#{factory}_on", :immediate, *args, &task)
          elsif ConcurrentRails::Testing.fake?
            task.call(*args)
          else
            super(*args, &task)
          end
        end
      end

      def schedule(delay, *args, &)
        if ConcurrentRails::Testing.immediate?
          schedule_on(:immediate, delay, *args, &)
        elsif ConcurrentRails::Testing.fake?
          yield(*args)
        else
          super
        end
      end
    end

    ConcurrentRails::Promises.extend(TestingFuture)
  end
end
