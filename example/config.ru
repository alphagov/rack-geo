require File.join(File.dirname(__FILE__), 'councils')
require 'rack/geo'

set :run, false

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

use Rack::Geo
run Sinatra::Application
