require 'spec_helper'

require 'rack/geo/utils'
require 'base64'
require 'json'

describe Rack::Geo::Utils do
  let :utils do
    Class.new { include Rack::Geo::Utils }.new
  end

  it "can encode the GeoStack for cookie and header use" do
    utils.encode_stack({'key' => 'value'}).should == Base64.encode64({'key' => 'value'}.to_json)
  end

  it "can decode the GeoStack cookie/header" do
    utils.decode_stack(Base64.encode64({'key' => 'value'}.to_json)).should == {'key' => 'value'}
  end
end