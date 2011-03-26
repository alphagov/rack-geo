require 'rack/request'
require 'rack/response'
require 'rack/geo/utils'

module Rack
  class Geo
    include Utils

    attr_reader :request

    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Rack::Request.new(env)
      geo_stack = extract_geo_info
      # only a limited number of parameters count at the minute - postcode and country
      geo_params = request.params.select { |k,v| ['postcode', 'country' ].include?(k) }
      unless geo_params.empty?
        geo_stack = geo_stack.update(geo_params)
      end

      encoded_geo = encode_stack(geo_stack.to_hash)
      env['HTTP_X_ALPHAGOV_GEO'] = encoded_geo

      status, headers, body = @app.call(env)

      response = Rack::Response.new(body, status, headers)
      response.set_cookie('geo', {:value => encoded_geo, :domain => '.alphagov.co.uk', :path => '/'})
      response.finish
    end

    private

    def extract_geo_info
      if has_geo_cookie?
        return Geolib::GeoStack.new_from_hash(decode_stack(request.cookies['geo']))
      else
        return Geolib::GeoStack.new_from_ip(request.ip)
      end
    end
    
    def has_geo_cookie?
      request.cookies.has_key?('geo')
    end
  end
end
