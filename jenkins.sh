#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake spec
# cd example && bundle install && bundle exec rake test
