# frozen_string_literal: true

require "bundler/setup"

require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = ENV["VERBOSE"] == "1"
end

task default: :test
