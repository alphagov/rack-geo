# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "rack-geo"
  s.version     = "0.8.8"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Patterson", "Ben Griffiths", "James Stewart"]
  s.email       = ["matt@alphagov.co.uk", "ben@alphagov.co.uk", "jystewart@gmail.com"]
  s.homepage    = "http://github.com/alphagov/rack-geo"
  s.summary     = %q{Geo-providing Rack middleware}
  s.description = %q{Geo-providing Rack middleware}

  s.rubyforge_project = "rack-geo"

  s.files         = Dir[
    'lib/**/*',
    'README.md',
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['spec/**/*']
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'rack'
  s.add_dependency 'json'
  s.add_dependency 'geogov', '~> 0.0.10'

  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'mocha', '~> 0.9.0'
  s.add_development_dependency 'gem_publisher', '~> 1.1.1'
  s.add_development_dependency 'gemfury'
end
