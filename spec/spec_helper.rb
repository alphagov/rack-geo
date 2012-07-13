ENV["RACK_ENV"] ||= 'test'
app_root_path = File.expand_path("../", File.dirname(__FILE__))

require 'bundler'
Bundler.require(:default, ENV["RACK_ENV"])
require 'rspec/core'
require 'rspec/expectations'
require 'rspec/matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("spec/support/**/*.rb", app_root_path)].each { |f| require f }


require 'rack/geo'
require 'rack/test'

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

class Harness
  attr_reader :env

  def call(env)
    @env = env.dup
    [200, {}, "body"]
  end
end
