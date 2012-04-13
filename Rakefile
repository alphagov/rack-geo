# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

spec = Gem::Specification.load('rack-geo.gemspec')

Bundler::GemHelper.install_tasks

task :default => :spec
