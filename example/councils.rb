require 'rubygems'
require 'bundler/setup'
require 'sinatra'

configure do
end

set :views, File.dirname(__FILE__) + '/templates'

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

# root page
get '/' do
  erb :councils
end