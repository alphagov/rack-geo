# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'rake/gempackagetask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

spec = Gem::Specification.load('rack-geo.gemspec')
Rake::GemPackageTask.new(spec) do
end

task :default => :spec
