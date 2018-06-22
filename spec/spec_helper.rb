require 'simplecov'
SimpleCov.start do
  add_filter 'lib/api_client_builder/version.rb'
  add_filter 'spec'
  track_files 'lib/**/*.rb'
end
SimpleCov.minimum_coverage(97)

require 'bundler/setup'
require 'api_client_builder'
