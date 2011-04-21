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

  let :harness do
    Harness.new
  end

  let :geostack do
    Geolib::GeoStack.new({})
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
      Geolib::GeoStack.stubs(:new_from_ip).returns(geostack)
      geostack.stubs(:to_hash).returns({'GEOSTACK' => 'ENCODED'})
    end

    it "should be given a new geostack based on ip address" do
      Geolib::GeoStack.expects(:new_from_ip).with('127.0.0.1').returns(geostack)
      get "/"
    end

    context "and rack-geo" do
      before(:each) do
        get "/"
      end

      it "should add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        Utils.decode_stack(harness.env['HTTP_X_ALPHAGOV_GEO']).should == {'GEOSTACK' => 'ENCODED'}
      end

      it "should add a Geo cookie to the response" do
        last_response_cookies.should have_key('geo')
        Utils.decode_stack(last_response_cookies['geo']).should == {'GEOSTACK' => 'ENCODED'}
      end
    end
  end

  describe "A returning visitor" do
    before(:each) do
      current_session.set_cookie("geo=#{Utils.encode_stack({'geo' => 'stack'})}; domain=example.org; path=/")
    end

    it "should be given a geostack from their cookie, on get request" do
      Geolib::GeoStack.expects(:new_from_hash).with do |stack|
        stack['geo'].should == 'stack'
      end.returns(geostack)
      get "/"
    end

    it "should be given a geostack from their cookie, on post request" do
      Geolib::GeoStack.expects(:new_from_hash).with do |stack|
        stack['geo'].should == 'stack'
      end.returns(geostack)
      post "/"
    end

    context "and rack-geo" do
      before(:each) do
        get "/"
      end

      it "should add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        JSON.parse(Base64.decode64(harness.env['HTTP_X_ALPHAGOV_GEO'])).should == {'geo' => 'stack'}
      end

      it "should add a Geo cookie to the response" do
        last_response_cookies.should have_key('geo')
        JSON.parse(Base64.decode64(last_response_cookies['geo'])).should == {'geo' => 'stack'}
      end
    end
  end

  describe "A visitor giving extra geo data" do
    before(:each) do
      Geolib::GeoStack.stubs(:new_from_hash).with('postcode' => 'W12 7RJ').returns(geostack)
      current_session.set_cookie("geo=#{Utils.encode_stack({'postcode' => 'W12 7RJ'})}; domain=example.org; path=/")
      @new_stack = Geolib::GeoStack.new({:dummy_prop => true})      
    end

    it "should be given a geostack updated with new params" do
      geostack.expects(:update).with('postcode' => 'W1A 1AA').returns(@new_stack)
      post "/", "postcode" => "W1A 1AA"
    end

    context "and rack-geo" do
      before(:each) do
        geostack.stubs(:update).with('postcode' => 'W1A 1AA').returns(@new_stack)
        post "/", "postcode" => "W1A 1AA"
      end

      it "should add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        harness.env['HTTP_X_ALPHAGOV_GEO'].should == Utils.encode_stack(@new_stack.to_hash)
      end

      it "should add a Geo cookie to the response" do
        last_response_cookies.should have_key('geo')
        last_response_cookies['geo'].should == Utils.encode_stack(@new_stack.to_hash)
      end
    end
  end

  describe "An app hitting /locator.json" do
    before(:each) do
      @new_stack = Geolib::GeoStack.new_from_hash({:fuzzy_point => {'lat' => '0', 'lon' => '0', 'accuracy' => :planet}, :friendly_name => 'Test'})
      Geolib::GeoStack.stubs(:new_from_ip).returns(@new_stack)
    end

    it "should return a JSON object" do
      post "/locator.json", :postcode => "W1A 1AA"
      JSON.parse(last_response.body).should == {'current_location' => {'lat' => '0', 'lon' => '0', 'locality' => 'Test', 'postcode' => 'W1A 1AA'}}
    end

    it "should return the cookie" do
      post "/locator.json", :postcode => "W1A 1AA"
      last_response_cookies.should have_key('geo')
      last_response_cookies['geo'].should == Utils.encode_stack(@new_stack.to_hash)
    end

    it "should not call the harness" do
      harness.expects(:call).never
      post "/locator.json", :postcode => "W1A 1AA"
    end
  end
end
