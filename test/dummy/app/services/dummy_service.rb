# frozen_string_literal: true

class DummyService
  class << self
    def do_something
      future = ConcurrentRails::Future.new do
        42
      end.execute

      future.value
    end
  end
end
