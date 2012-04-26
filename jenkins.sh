#!/bin/bash -x

# Gemfile.lock is not in source control because this is a gem.
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake spec
# cd example && bundle install && bundle exec rake test
