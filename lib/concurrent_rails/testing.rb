# frozen_string_literal: true

class ConcurrentRails::Testing
  class << self
    attr_reader :execution_mode

    %i[immediate fake].each do |test_mode|
      define_method("#{test_mode}!") do |&task|
        @execution_mode = test_mode
        result = task.call
        @execution_mode = :real

        result
      end

      define_method("#{test_mode}?") do
        execution_mode == test_mode
      end
    end

    module TestingFuture
      def future(*args, &task)
        if ConcurrentRails::Testing.immediate?
          future_on(:immediate, *args, &task)
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
