# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

puts "here"
require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = "#{File.expand_path('fixtures', __dir__)}/files"
  ActiveSupport::TestCase.fixtures :all
end

require "minitest/reporters"
require "rails/test_unit/reporter"

Minitest::Reporters.use!

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false
load "#{Rails.root}/db/schema.rb"

Rails::TestUnitReporter.executable = "bin/test"
