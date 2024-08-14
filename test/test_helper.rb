# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "minitest/reporters"
require "rails/test_help"
require "rails/test_unit/reporter"

Minitest::Reporters.use!

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false
load "#{Rails.root}/db/schema.rb"

Rails::TestUnitReporter.executable = "bin/test"
