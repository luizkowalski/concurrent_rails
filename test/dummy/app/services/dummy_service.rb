# frozen_string_literal: true

class DummyService
  class << self
    def do_something
      future = ConcurrentRails::Promises.future do
        42
      end

      future.value
    end
  end
end
