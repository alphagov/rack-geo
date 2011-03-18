require 'json'
require 'base64'

module Rack
  class Geo
    module Utils
      def encode_stack(stack)
        Base64.strict_encode64(stack.to_json)
      end
      
      def decode_stack(encoded_stack)
        JSON.parse(Base64.decode64(encoded_stack))
      end
    end
  end
end