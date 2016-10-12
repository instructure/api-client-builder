# -*- encoding: utf-8 -*-
require File.expand_path('../lib/api_client_builder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "api_client_builder"
  gem.summary       = "API Client Builder provides an easy to use interface for creating HTTP api clients"
  gem.description   = "API Client Builder provides an easy to use interface for creating HTTP api clients"
  gem.authors       = ['Jayce Higgins']
  gem.email         = ['jaycekhiggins@gmail.com']

  gem.files         = %w[api_client_builder.gemspec readme.md]

  gem.test_files    = Dir.glob("spec/**/*")
  gem.require_paths = ["lib"]
  gem.version       = APIClientBuilder::VERSION
  gem.required_ruby_version = '>= 2.0'

  gem.license       = 'MIT'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
