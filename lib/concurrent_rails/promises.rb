# frozen_string_literal: true

module ConcurrentRails
  class Promises
    class << self
      def future(*args, &)
        future_on(:io, *args, &)
      end

      def future_on(executor, *args, &task)
        new(executor, Concurrent::Promises.future_on(executor, *args, &wrap_task(task)))
      end

      def delay(*args, &)
        delay_on(:io, *args, &)
      end

      def delay_on(executor, *args, &task)
        new(executor, Concurrent::Promises.delay_on(executor, *args, &wrap_task(task)))
      end

      def schedule(*args, &)
        schedule_on(:io, *args, &)
      end

      def schedule_on(executor, *args, &task)
        new(executor, Concurrent::Promises.schedule_on(executor, *args, &wrap_task(task)))
      end

      def zip(*promises)
        new(:io, Concurrent::Promises.zip(*unwrap(promises)))
      end

      def any_resolved_future(*promises)
        new(:io, Concurrent::Promises.any_resolved_future(*unwrap(promises)))
      end

      def fulfilled_future(value, executor = :io)
        new(executor, Concurrent::Promises.fulfilled_future(value))
      end

      def rejected_future(reason, executor = :io)
        new(executor, Concurrent::Promises.rejected_future(reason))
      end

      def wrap_task(task)
        proc { |*args| Rails.application.executor.wrap { task.call(*args) } }
      end

      private

      def unwrap(promises)
        promises.map { |p| p.is_a?(Promises) ? p.__send__(:instance) : p }
      end
    end

    def initialize(executor, instance)
      @executor = executor
      @instance = instance
    end

    def value(timeout = nil, timeout_value = nil)
      rails_wrapped { instance.value(timeout, timeout_value) }
    end

    def value!(timeout = nil, timeout_value = nil)
      rails_wrapped { instance.value!(timeout, timeout_value) }
    end

    def then(*args, &task)
      self.class.new(executor, instance.then_on(executor, *args, &self.class.wrap_task(task)))
    end

    def chain(*args, &task)
      self.class.new(executor, instance.chain_on(executor, *args, &self.class.wrap_task(task)))
    end

    def touch
      instance.touch

      self
    end

    def wait(timeout = nil)
      result = rails_wrapped { instance.wait(timeout) }

      timeout ? result : self
    end

    def on_fulfillment(*args, &callback_task)
      instance.on_fulfillment_using(executor, *args, &self.class.wrap_task(callback_task))

      self
    end

    def on_fulfillment!(*args, &callback_task)
      instance.on_fulfillment!(*args, &self.class.wrap_task(callback_task))

      self
    end

    def on_rejection(*args, &callback_task)
      instance.on_rejection_using(executor, *args, &self.class.wrap_task(callback_task))

      self
    end

    def on_rejection!(*args, &callback_task)
      instance.on_rejection!(*args, &self.class.wrap_task(callback_task))

      self
    end

    def on_resolution(*args, &callback_task)
      instance.on_resolution_using(executor, *args, &self.class.wrap_task(callback_task))

      self
    end

    def on_resolution!(*args, &callback_task)
      instance.on_resolution!(*args, &self.class.wrap_task(callback_task))

      self
    end

    def state      = instance.state
    def reason     = instance.reason
    def rejected?  = instance.rejected?
    def resolved?  = instance.resolved?
    def fulfilled? = instance.fulfilled?

    attr_reader :executor

    private

    def rails_wrapped(&)
      Rails.application.executor.wrap(&)
    end

    attr_reader :instance
  end
end
