require 'spec_helper'

require 'rack/geo/utils'
require 'base64'
require 'json'

describe Rack::Geo::Utils do
  let :utils do
    Class.new { include Rack::Geo::Utils }.new
  end

  it "can encode the GeoStack for cookie and header use" do
    Base64.decode64(utils.encode_stack({'key' => 'value'})).should == {'key' => 'value'}.to_json
  end

  it "can decode the GeoStack cookie/header" do
    utils.decode_stack(Base64.encode64({'key' => 'value'}.to_json)).should == {'key' => 'value'}
  end

  describe "headers long enough to hit default Base64 encoding-added newlines" do
    it "avoids adding the newlines" do
      utils.encode_stack({'key' => 'value'*64}).should_not == Base64.encode64({'key' => 'value'*64}.to_json)
    end

    it "can be decoded" do
      utils.decode_stack(utils.encode_stack({'key' => 'value'*64})).should == {'key' => 'value'*64}
    end
  end
  
  describe "figuring out what the sensible cookie domain should be" do
    it "returns .alpha.gov.uk given an alpha.gov.uk request" do
      utils.cookie_domain_from_host('alpha.gov.uk').should == '.alpha.gov.uk'
    end

    it "returns .alphagov.co.uk given an x.alphagov.gov.uk request" do
      utils.cookie_domain_from_host('production.alphagov.co.uk').should == '.alphagov.co.uk'
    end
  end
end