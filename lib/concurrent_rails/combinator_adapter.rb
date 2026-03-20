# frozen_string_literal: true

module ConcurrentRails
  module CombinatorAdapter
    extend ActiveSupport::Concern

    class_methods do
      def zip(*promises)
        futures = promises.map { |p| p.is_a?(ConcurrentRails::Promises) ? p.__send__(:instance) : p }
        new(:io).tap { |p| p.instance_variable_set(:@instance, Concurrent::Promises.zip(*futures)) }
      end

      def any_resolved_future(*promises)
        futures = promises.map { |p| p.is_a?(ConcurrentRails::Promises) ? p.__send__(:instance) : p }
        new(:io).tap { |p| p.instance_variable_set(:@instance, Concurrent::Promises.any_resolved_future(*futures)) }
      end

      def fulfilled_future(value, executor = :io)
        new(executor).tap { |p| p.instance_variable_set(:@instance, Concurrent::Promises.fulfilled_future(value)) }
      end

      def rejected_future(reason, executor = :io)
        new(executor).tap { |p| p.instance_variable_set(:@instance, Concurrent::Promises.rejected_future(reason)) }
      end
    end
  end
end
