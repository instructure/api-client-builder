#!/usr/bin/env bash

set -e

docker pull ruby:2.7

for version in '2.7'; do
  echo "Testing Ruby $version..."
  docker run --rm -v "`pwd`:/app" -w /app --user `id -u`:`id -g` \
    -e HOME="/tmp" "ruby:$version" /bin/sh -c \
    "echo \"gem: --no-document\" >> ~/.gemrc && bundle install --jobs 5 --quiet && bundle exec rspec"
done
