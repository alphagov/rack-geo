# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "rack-geo"
  s.version     = "0.7.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Patterson","Ben Griffiths"]
  s.email       = ["matt@alphagov.co.uk","ben@alphagov.co.uk"]
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
  s.add_dependency 'geogov'

  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'mocha', '~> 0.9.0'
end
