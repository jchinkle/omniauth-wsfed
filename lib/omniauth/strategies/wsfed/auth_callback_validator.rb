module OmniAuth
  module Strategies
    class WSFed

      class AuthCallbackValidator

        attr_accessor :auth_callback, :wsfed_settings

        ISSUER_MISMATCH     = 'AuthN token issuer does not match configured issuer.'
        AUDIENCE_MISMATCH   = 'AuthN token audience does not match configured realm.'
        FUTURE_CREATED_AT   = 'AuthN token created timestamp occurs in the future.'
        TOKEN_EXPIRED       = 'AuthN token has expired.'
        NO_CLAIMS           = 'AuthN token contains no claims.'
        NO_USER_IDENTIFIER  = 'AuthN token contains no user identifier. Verify that configured :id_claim setting is correct.'

        def initialize(auth_callback, wsfed_settings)
          self.auth_callback  = auth_callback
          self.wsfed_settings = wsfed_settings
        end

        def validate!
          raise OmniAuth::Strategies::WSFed::ValidationError.new(ISSUER_MISMATCH) unless
            auth_callback.issuer == wsfed_settings[:issuer_name]

          raise OmniAuth::Strategies::WSFed::ValidationError.new(AUDIENCE_MISMATCH) unless
            auth_callback.audience == wsfed_settings[:realm]

          raise OmniAuth::Strategies::WSFed::ValidationError.new(FUTURE_CREATED_AT) unless
            auth_callback.created_at < Time.now.utc

          raise OmniAuth::Strategies::WSFed::ValidationError.new(TOKEN_EXPIRED) unless
            auth_callback.expires_at > Time.now.utc

          if auth_callback.claims.nil? || auth_callback.claims.empty?
            raise OmniAuth::Strategies::WSFed::ValidationError.new(NO_CLAIMS)
          end

          if auth_callback.name_id.nil? || auth_callback.name_id.empty?
            raise OmniAuth::Strategies::WSFed::ValidationError.new(NO_USER_IDENTIFIER)
          end

          true
        end

      end

    end
  end
end