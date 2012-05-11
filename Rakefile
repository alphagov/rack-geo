# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

spec = Gem::Specification.load('rack-geo.gemspec')

Bundler::GemHelper.install_tasks

task :default => :spec

require "gem_publisher"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("rack-geo.gemspec", :gemfury)
  puts "Published #{gem}" if gem
end
