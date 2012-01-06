require 'spec_helper'
require 'base64'
require 'rack/utils'

module Utils
  extend Rack::Geo::Utils
end

describe Rack::Geo do
  include Rack::Test::Methods

  def last_response_cookies
    Rack::Utils.parse_query(last_response['Set-Cookie'], ';,')
  end

  before(:each) do
    @geostack = Geogov::GeoStack.new_from_hash({'fuzzy_point' => {'lat' => 0, 'lon' => 0, 'accuracy' => :planet}})
  end

  let :harness do
    Harness.new
  end

  let :app do
    the_harness = harness
    Rack::Builder.new do
      use Rack::Geo
      run the_harness
    end
  end

  describe "A first time visitor" do
    before(:each) do
      Geogov::GeoStack.stubs(:new).returns(@geostack)
      @geostack.stubs(:to_hash).returns({'GEOSTACK' => 'ENCODED'})
    end

    it "should not be given a new geostack based on ip address" do
      Geogov::GeoStack.expects(:new_from_ip).never
      get "/"
    end

    context "and rack-geo" do
      before(:each) do
        get "/"
      end

      it "should add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_GOVGEO_STACK')
        Utils.decode_stack(harness.env['HTTP_X_GOVGEO_STACK']).should == {'GEOSTACK' => 'ENCODED'}
      end

      it "should no longer add a Geo cookie to the response" do
        last_response_cookies.should_not have_key('geo')
      end
    end
  end

  describe "An app hitting /locator.*" do
    before(:each) do
      @new_stack = Geogov::GeoStack.new_from_hash({'fuzzy_point' => {'lat' => '51.0', 'lon' => '0.0', 'accuracy' => :ward}, 'friendly_name' => 'Test'})
      Geogov::GeoStack.stubs(:new_from_ip).returns(@new_stack)
    end

    context "successfully with JSON" do
      it "should return a JSON object containing the lat, lon, name, and postcode" do
        post "/locator.json", :postcode => "W1A 1AA"
        result = JSON.parse(last_response.body)
        result.should have_key('current_location')
        ['lat', 'lon', 'locality', 'postcode'].each do |key|
          result['current_location'].should have_key(key)
        end
      end

      it "should no longer return the cookie" do
        post "/locator.json", :postcode => "W1A 1AA"
        last_response_cookies.should_not have_key('geo')
      end

      it "should not call the app Rack-geo is wrapping" do
        harness.expects(:call).never
        post "/locator.json", :postcode => "W1A 1AA"
      end
    end

    context "successfully with HTML" do
      it "should redirect back to the set location page" do
        post "/locator.html", :postcode => "W1A 1AA"
        last_response.should be_redirect
        last_response.headers['Location'].should == "http://example.org/set-my-location"
      end
    end

    context "with a duff postcode" do
      it "should return a JSON object containing the duff postcode and an error" do
        post "/locator.json", :postcode => "W1A 1ABC"
        JSON.parse(last_response.body).should == {'location_error' => {'postcode' => 'W1A 1ABC'}}
      end
    end
  end
end
