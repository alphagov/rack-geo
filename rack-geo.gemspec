# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "rack-geo"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Patterson"]
  s.email       = ["matt@reprocessed.org"]
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

  s.add_dependency 'rack', '~> 1.2.0'
end
