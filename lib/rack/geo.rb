require 'geogov'
require 'rack/request'
require 'rack/response'
require 'rack/geo/utils'
require 'json'

module Rack
  class Geo
    include Utils

    attr_reader :request

    def initialize(app, options = {})
      @app = app
      @auto_geoip_lookup = options.has_key?(:auto_geoip_lookup)
    end

    def pass_thru(env)
       @app.call(env)
    end

    COMMON_STATIC_PATHS = %r{\.png$|\.css$|\.jpeg$|\.jpg$|/javascript/}

    def call(env)
      @request = Rack::Request.new(env)

      if request.path == "/javascripts/rack-geo.js"
        public_dir = ::File.dirname(__FILE__)+"/../../public"
        return Rack::File.new(public_dir).call(env)
      end

      if request.path =~ COMMON_STATIC_PATHS
        return pass_thru(env)
      end

      geo_stack = process_geo_params(request.params)
      encoded_geo = encode_stack(geo_stack.to_hash)

      if request.path =~ /locator\.(json|html)$/
        if request.request_method == "GET"
          return [400, {"Content-Type" => "text/plain"}, ["GET geolocation requests are not allowed"]]
        else
          return handle_geo_lookup($1, geo_stack, encoded_geo, env)
        end
      end

      env['HTTP_X_GOVGEO_STACK'] = encoded_geo

      status, headers, body = @app.call(env)
      generate_response(status, headers, body, request.host, encoded_geo)
    end

    private

    def handle_geo_lookup(format, geo_stack, encoded_geo, env)
      if geo_stack.fuzzy_point.accuracy == :planet
        response_hash = {'location_error' => true}
      else
        response_hash = {'current_location' => generate_simple_geo_hash(geo_stack.to_hash, request.params)}
      end
      
      response_pieces = [request.host, encoded_geo]

      case format
      when 'json'
        response_pieces = [200, {'Content-Type' => 'application/json; charset=utf-8'}, response_hash.to_json] + response_pieces
      else
        location = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/set-my-location"
        response_pieces = [302, {'Content-Type' => 'text','Location' => location}, ['302 found']] + response_pieces
      end
      
      return generate_response(*response_pieces)
    end

    def process_geo_params(params)
      if params['reset_geo']
        geo_stack = Geogov::GeoStack.new_from_ip(request.ip)
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
        :nation   => geo_stack_hash[:nation]
      }
      simple_geo_hash
    end

    def generate_response(status, headers, body, request_host, encoded_geo_stack)
      response = Rack::Response.new(body, status, headers)
      response.finish
    end

    def extract_geo_info
      if @auto_geoip_lookup
        Geogov::GeoStack.new_from_ip(request.ip)
      else
        Geogov::GeoStack.new
      end
    end

  end
end
