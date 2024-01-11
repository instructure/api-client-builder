#!/bin/bash

set -e

current_version=$(ruby -e "require '$(pwd)/lib/api_client_builder/version.rb'; puts APIClientBuilder::VERSION;")

if gem list --exact api_client_builder --remote --all | grep -o '\((.*)\)$' | tr '() ,'  '\n' | grep -xF "$current_version"; then
  echo "Gem has already been published ... skipping ..."
else
  gem build ./api_client_builder.gemspec
  find api_client_builder-*.gem | xargs gem push
fi
