# frozen_string_literal: true

module ConcurrentRails::Adapters
  module Delay
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
      @instance = rails_wrapped { delay_on(executor, *args, &task) }

      self
    end

    %i[on_fulfillment on_rejection on_resolution].each do |method|
      define_method(method) do |*args, &callback|
        rails_wrapped do
          @instance = instance.__send__("#{method}_using", executor, *args, &callback)
        end

        self
      end

      define_method("#{method}!") do |*args, &callback|
        rails_wrapped do
          @instance = instance.__send__(:add_callback, "callback_#{method}", args, callback)
        end

        self
      end
    end

    delegate :touch, :wait, to: :instance

    private

    attr_reader :instance
  end
end
