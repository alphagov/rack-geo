#!/bin/bash -x
set -e

# Gemfile.lock is not in source control because this is a gem.
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake spec
bundle exec rake publish_gem
