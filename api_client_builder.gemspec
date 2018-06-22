require File.expand_path('lib/api_client_builder/version', __dir__)

Gem::Specification.new do |gem|
  gem.name          = 'api_client_builder'
  gem.summary       = 'API Client Builder provides an easy to use interface for creating HTTP api clients'
  gem.description   = 'API Client Builder provides an easy to use interface for creating HTTP api clients'
  gem.authors       = ['Jayce Higgins']
  gem.email         = ['jhiggins@instructure.com', 'eng@instructure.com']
  gem.homepage      = 'https://github.com/instructure/api-client-builder'

  gem.version       = APIClientBuilder::VERSION
  gem.required_ruby_version = '>= 2.3'

  gem.license = 'MIT'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rspec', '~> 3.7'
  gem.add_development_dependency 'rubocop', '~> 0.57.2'
  gem.add_development_dependency 'simplecov', '~> 0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']
end
