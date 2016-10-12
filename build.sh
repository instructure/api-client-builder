#!/bin/bash

bundle check || bundle install

EXIT_CODES=0

bundle exec rspec

exit $EXIT_CODES
