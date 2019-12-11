# frozen_string_literal: true

require 'sinatra/base'

class OAuthTokenService < Sinatra::Base
  post '' do
    token = JWT.encode({}, ENV['JWT_SECRET'], 'HS256')
    status 200
    { access_token: token, expires_in: 3_600, token_type: 'bearer' }.to_json
  end
end
