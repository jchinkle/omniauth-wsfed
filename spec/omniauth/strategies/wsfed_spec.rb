require 'spec_helper'

# Had to split these tests into two different classes because the OmniAuth::Test::StrategyTestCase only sets up one
# instance of the strategy settings per spec description. In other words, any time you need to make changes to the
# OmniAuth initialization settings, you need a new spec description to re-initialize the test strategy.

describe OmniAuth::Strategies::WSFed, :type => :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash){ last_request.env['omniauth.auth'] }
  let(:wsfed_settings) do
    {
        issuer: "https://c4sc.accesscontrol.windows.net.com/v2/wsfederation",
        realm:  "http://c4sc.com/security_realm",
        reply:  "http://rp.c4sc.com/auth/wsfed"
    }
  end
  let(:strategy) { [OmniAuth::Strategies::WSFed, wsfed_settings] }
  let(:home_realm) { "http://identity.c4sc.com/trust" }


  describe 'request_phase: GET /auth/wsfed' do

    context 'no :home_realm_discovery_path' do

      it 'should redirect to the IdP/FP issuer URL without [whr] param'  do
        get '/auth/wsfed'

        last_response.should be_redirect
        last_response.location.should include wsfed_settings[:issuer]
      end

      it 'should redirect to the IdP/FP Issuer URL and maintain [whr] param' do
        get "auth/wsfed?whr=#{home_realm}"

        last_response.should be_redirect
        last_response.location.should include wsfed_settings[:issuer]
        last_response.location.should include "whr=#{ERB::Util::url_encode(home_realm)}"
      end

    end

  end

end

describe OmniAuth::Strategies::WSFed, :type => :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:home_realm_discovery) { "/auth/wsfed/home_realm_discovery" }
  let(:wsfed_settings) do
    {
        issuer:                     "https://c4sc.accesscontrol.windows.net.com/v2/wsfederation",
        realm:                      "http://c4sc.com/security_realm",
        reply:                      "http://rp.c4sc.com/auth/wsfed",
        home_realm_discovery_path:  home_realm_discovery
    }
  end
  let(:strategy) { [OmniAuth::Strategies::WSFed, wsfed_settings] }
  let(:home_realm) { "http://identity.c4sc.com/trust" }

  context ':home_realm_discovery_path configured' do

    it 'should redirect to the local home realm discovery path without [whr] param'  do
      get '/auth/wsfed'

      last_response.should be_redirect
      last_response.location.should == home_realm_discovery
    end

    it 'should redirect to the IdP/FP Issuer URL and maintain [whr] param' do
      get "auth/wsfed?whr=#{home_realm}"

      last_response.should be_redirect
      last_response.location.should include wsfed_settings[:issuer]
      last_response.location.should include "whr=#{ERB::Util::url_encode(home_realm)}"
    end

  end
end


