# frozen_string_literal: true

module ConcurrentRails
  class Railtie < ::Rails::Railtie
    initializer "concurrent_rails.executor_hooks" do |app|
      app.executor.to_run { nil }
      app.executor.to_complete { nil }
    end
  end
end
