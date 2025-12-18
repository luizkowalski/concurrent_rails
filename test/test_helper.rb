# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

ActiveRecord::Schema.verbose = false
load "#{Rails.root}/db/schema.rb" # Load the schema for the test database
