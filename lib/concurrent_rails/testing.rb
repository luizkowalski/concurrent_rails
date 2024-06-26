# frozen_string_literal: true

module ConcurrentRails
  class Testing
    class << self
      attr_reader :execution_mode

      %w[immediate fake real].each do |test_mode|
        define_method(test_mode) do |&task|
          @execution_mode = test_mode
          result          = task.call
          @execution_mode = :real

          result
        end

        define_method(:"#{test_mode}!") do
          @execution_mode = test_mode
        end

        define_method(:"#{test_mode}?") do
          execution_mode == test_mode
        end
      end
    end

    module TestingFuture
      def future(*args, &)
        if ConcurrentRails::Testing.immediate?
          future_on(:immediate, *args, &)
        elsif ConcurrentRails::Testing.fake?
          yield
        else
          super
        end
      end
    end

    ConcurrentRails::Promises.extend(TestingFuture)
  end
end
