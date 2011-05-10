require 'rack/request'
require 'rack/response'
require 'rack/geo/utils'
require 'json'

module Rack
  class Geo
    include Utils

    attr_reader :request

    def initialize(app)
      @app = app
    end

    def pass_thru(env)
       @app.call(env)
    end

    def call(env)
      @request = Rack::Request.new(env)

      if request.path =~ /\.png$|\.css$|\.jpeg$|\.jpg$|\/javascript\//
        return pass_thru(env)
      end

      geo_stack = process_geo_params(request.params)
      encoded_geo = encode_stack(geo_stack.to_hash)

      if request.path =~ /locator\.json$/
        if geo_stack.fuzzy_point.accuracy == :planet
          response_hash = {'location_error' => generate_geo_error_hash(request.params)}
        else
          response_hash = {'current_location' => generate_simple_geo_hash(geo_stack.to_hash, request.params)}
        end
        return generate_response(
          200, 
          {'Content-Type' => 'application/json; charset=utf-8'}, 
          response_hash.to_json,
          request.host,
          encoded_geo
        )
      end
      env['HTTP_X_ALPHAGOV_GEO'] = encoded_geo

      status, headers, body = @app.call(env)
      generate_response(status, headers, body, request.host, encoded_geo)
    end

    private

    def process_geo_params(params)
      if params['reset_geo']
        geo_stack = Geolib::GeoStack.new_from_ip(request.ip)
      else
        geo_stack = extract_geo_info

        # only limited number of parameters count at the minute - postcode and country
        geo_params = params.select { |k,v| ['lon', 'lat', 'postcode', 'country' ].include?(k) }
        unless geo_params.empty?
          geo_stack = geo_stack.update(geo_params)
        end
      end
      geo_stack
    end

    def generate_simple_geo_hash(geo_stack_hash, params)
      councils = []
      councils = councils + geo_stack_hash[:ward] if geo_stack_hash[:ward]
      councils = councils + geo_stack_hash[:council] if geo_stack_hash[:council]
      simple_geo_hash = {
        :lat      => geo_stack_hash[:fuzzy_point]['lat'], 
        :lon      => geo_stack_hash[:fuzzy_point]['lon'], 
        :locality => geo_stack_hash[:friendly_name],
        :ward     => geo_stack_hash[:ward],
        :council  => geo_stack_hash[:council],
        :councils => councils,
      }
      simple_geo_hash[:postcode] = params['postcode'] if params.has_key?('postcode')
      simple_geo_hash
    end

    def generate_geo_error_hash(params)
      geo_error_hash = {}
      geo_error_hash[:postcode] = params['postcode'] if params.has_key?('postcode')
      geo_error_hash
    end

    def generate_response(status, headers, body, request_host, encoded_geo_stack)
      response = Rack::Response.new(body, status, headers)
      response.set_cookie('geo', {:value => encoded_geo_stack, :domain => cookie_domain_from_host(request_host), :path => '/'})
      response.finish
    end

    def extract_geo_info
      if has_geo_cookie?
        return Geolib::GeoStack.new_from_hash(decode_stack(request.cookies['geo']))
      else
        stack = Geolib::GeoStack.new_from_ip(request.ip)
        return stack
      end
    end
    
    def has_geo_cookie?
      request.cookies && request.cookies.has_key?('geo')
    end
  end
end
