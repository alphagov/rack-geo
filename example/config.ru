require File.join(File.dirname(__FILE__), 'councils')

require "bundler"
Bundler.require(:default, ENV['RACK_ENV'])

set :run, false

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

use Rack::Geo

static_dir = "../../static/public"

use Rack::Static, :urls => ["/stylesheets","/javascripts", "/images","/templates"], :root => static_dir
use Slimmer::App, :template_host => static_dir + "/templates"

run Sinatra::Application
