# frozen_string_literal: true

require_relative "lib/concurrent_rails/version"

Gem::Specification.new do |spec|
  spec.name        = "concurrent_rails"
  spec.version     = ConcurrentRails::VERSION
  spec.authors     = ["Luiz Eduardo Kowalski"]
  spec.email       = ["luizeduardokowalski@gmail.com"]
  spec.homepage    = "https://github.com/luizkowalski/concurrent_rails"
  spec.summary     = "Multithread is hard"
  spec.description = "Small library to make concurrent-ruby and Rails play nice together"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "https://github.com/luizkowalski/concurrent_rails/blob/master/CHANGELOG.md"
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "zeitwerk"

  spec.required_ruby_version = ">= 3.2"
  spec.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
