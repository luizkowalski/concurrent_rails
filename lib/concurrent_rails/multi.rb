# frozen_string_literal: true

module ConcurrentRails
  class Multi
    def self.enqueue(*actions, executor: :io)
      unless actions.all? { |action| action.is_a?(Proc) }
        raise ArgumentError, '#enqueue accepts `Proc`s only'
      end

      new(actions, executor).enqueue
    end

    def initialize(actions, executor)
      @actions    = actions
      @executor   = executor
      @exceptions = Concurrent::Array.new
    end

    def enqueue
      @futures = actions.map do |action|
        f = ConcurrentRails::Future.new(executor: executor, &action)
        f.add_observer(self)
        f.execute
      end

      self
    end

    def compute
      futures.map(&:value)
    end

    def compute!
      futures.map(&:value!)
    end

    def complete?
      futures.all?(&:complete?)
    end

    def errors
      @exceptions
    end

    private

    def update(_time, _value, reason)
      @exceptions << reason if reason
    end

    attr_reader :actions, :futures, :exceptions, :executor
  end
end
