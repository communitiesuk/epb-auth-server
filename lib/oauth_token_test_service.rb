# frozen_string_literal: true

require 'epb_auth_tools'
require 'sinatra/base'

class OAuthTokenTestService < Sinatra::Base
  set(:jwt) do
    condition do
      jwt_token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      processor = Auth::TokenProcessor.new ENV['JWT_SECRET'], ENV['JWT_ISSUER']

      processor.process jwt_token
    rescue Auth::TokenMalformed
      halt 401
    end
  end

  get '', jwt: [] do
    content_type :json
    { message: 'ok' }.to_json
  end
end
