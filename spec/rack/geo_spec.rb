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

  let :empty_stack do
    Geolib::GeoStack.new({})
  end

  let :app do
    the_harness = harness
    Rack::Builder.new do
      use Rack::Geo
      run the_harness
    end
  end

  describe "for a GET request with no Geo cookie set" do
    before(:each) do
      Geolib::GeoStack.stubs(:from_hash).returns(empty_stack)
      empty_stack.stubs(:to_hash).returns({'GEOSTACK' => 'ENCODED'})
    end

    it "should attempt to use Geo IP to locate the user" do
      Geolib::GeoStack.expects(:from_hash).with({:ip_address => '127.0.0.1'}).returns(empty_stack)
      get "/"
    end


    context "after the request has hit the app" do
      before(:each) do
        get "/"
      end

      it "add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        Utils.decode_stack(harness.env['HTTP_X_ALPHAGOV_GEO']).should == {'GEOSTACK' => 'ENCODED'}
      end

      it "should add a Geo cookie to the response" do
        last_response_cookies.should have_key('geo')
        Utils.decode_stack(last_response_cookies['geo']).should == {'GEOSTACK' => 'ENCODED'}
      end
    end
  end

  describe "for a GET request with a Geo cookie set" do
    before(:each) do
      current_session.set_cookie("geo=#{Utils.encode_stack({'geo' => 'stack'})}")
    end

    it "should create a GeoStack using the cookie" do
      Geolib::GeoStack.expects(:from_hash).with do |stack|
        stack['geo'].should == 'stack'
      end.returns(empty_stack)
      get "/"
    end

    it "should not attempt to use Geo IP to locate the user" do
      Geolib::GeoStack.expects(:from_hash).with do |stack|
        !stack.has_key?(:ip_address)
      end.returns(empty_stack)
      get "/"
    end

    context "after the request has hit the app" do
      before(:each) do
        get "/"
      end

      it "add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        JSON.parse(Base64.decode64(harness.env['HTTP_X_ALPHAGOV_GEO'])).should == {'geo' => 'stack'}
      end

      it "should add a Geo cookie to the response" do
        last_response_cookies.should have_key('geo')
        JSON.parse(Base64.decode64(last_response_cookies['geo'])).should == {'geo' => 'stack'}
      end
    end
  end

  describe "for a POST request with a Geo cookie set" do
    before(:each) do
      current_session.set_cookie("geo=#{Utils.encode_stack({'postcode' => 'W12 7RJ'})}")
    end

    context "after the request has hit the app" do
      before(:each) do
        post "/", "postcode" => "W1A 1AA"
      end

      it "add a Geo header to the env for apps further down the chain" do
        harness.env.should have_key('HTTP_X_ALPHAGOV_GEO')
        Utils.decode_stack(harness.env['HTTP_X_ALPHAGOV_GEO']).should == {'postcode' => 'W1A 1AA'}
      end

      it "should update the Geo cookie in the response" do
        last_response_cookies.should have_key('geo')
        Utils.decode_stack(last_response_cookies['geo']).should == {'postcode' => 'W1A 1AA'}
      end
    end
  end
end