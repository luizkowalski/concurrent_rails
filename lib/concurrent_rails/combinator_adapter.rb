# frozen_string_literal: true

module ConcurrentRails
  module CombinatorAdapter
    extend ActiveSupport::Concern

    class_methods do
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

      private

      def unwrap(promises)
        promises.map { |p| p.is_a?(ConcurrentRails::Promises) ? p.__send__(:instance) : p }
      end
    end
  end
end
