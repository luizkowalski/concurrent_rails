# frozen_string_literal: true

class ConcurrentRails::Testing
  class << self
    attr_reader :execution_mode

    %i[immediate fake].each do |exec_method|
      define_method("#{exec_method}!") do |&task|
        @execution_mode = exec_method
        result = task.call
        @execution_mode = :real

        result
      end

      define_method("#{exec_method}?") do
        execution_mode == exec_method
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
