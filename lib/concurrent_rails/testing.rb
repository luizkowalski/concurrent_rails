# frozen_string_literal: true

module ConcurrentRails
  class Testing
    ISOLATION_KEY = :concurrent_rails_testing_mode

    class << self
      def execution_mode
        ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] || Ractor.current[ISOLATION_KEY] || "real"
      end

      def immediate(&)
        with_mode("immediate", &)
      end

      def immediate!
        Ractor.current[ISOLATION_KEY] = "immediate"
      end

      def immediate?
        execution_mode == "immediate"
      end

      def fake(&)
        with_mode("fake", &)
      end

      def fake!
        Ractor.current[ISOLATION_KEY] = "fake"
      end

      def fake?
        execution_mode == "fake"
      end

      def real(&)
        with_mode("real", &)
      end

      def real!
        Ractor.current[ISOLATION_KEY] = "real"
      end

      def real?
        execution_mode == "real"
      end

      private

      def with_mode(mode)
        previous = ActiveSupport::IsolatedExecutionState[ISOLATION_KEY]
        ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] = mode

        yield
      ensure
        ActiveSupport::IsolatedExecutionState[ISOLATION_KEY] = previous
      end
    end

    module TestingFuture
      def future(*args, &)
        if ConcurrentRails::Testing.immediate?
          future_on(:immediate, *args, &)
        elsif ConcurrentRails::Testing.fake?
          yield(*args)
        else
          super
        end
      end

      def delay(*args, &)
        if ConcurrentRails::Testing.immediate?
          delay_on(:immediate, *args, &)
        elsif ConcurrentRails::Testing.fake?
          yield(*args)
        else
          super
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

    ConcurrentRails::Promises.singleton_class.prepend(TestingFuture)
  end
end
