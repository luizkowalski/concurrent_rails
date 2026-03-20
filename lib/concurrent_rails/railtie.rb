# frozen_string_literal: true

module ConcurrentRails
  class Railtie < ::Rails::Railtie
    initializer "concurrent_rails.executor_hooks" do |app|
      # TODO: Add something here at some point
    end
  end
end
