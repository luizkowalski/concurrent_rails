# frozen_string_literal: true

require_relative 'lib/concurrent_rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'concurrent_rails'
  spec.version     = ConcurrentRails::VERSION
  spec.authors     = ['Luiz Eduardo Kowalski']
  spec.email       = ['luizeduardokowalski@gmail.com']
  spec.homepage    = 'https://github.com/luizkowalski/concurrent_rails'
  spec.summary     = 'Multithread is hard'
  spec.description = 'Small library to make concurrent-ruby and Rails play nice together'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata['allowed_push_host'] = ": Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/luizkowalski/concurrent_rails/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 5.2'

  spec.add_development_dependency 'rubocop', '>= 1.12'
  spec.add_development_dependency 'rubocop-minitest', '>= 0.12'
  spec.add_development_dependency 'rubocop-performance', '>= 1.10'
  spec.add_development_dependency 'sqlite3', '~> 1.4'

  spec.required_ruby_version = '>= 2.6'
end
