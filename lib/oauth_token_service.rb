# frozen_string_literal: true

require 'sinatra/base'

class OAuthTokenService < Sinatra::Base
  post '' do
    content_type :json
    client = Client.resolve_from_request env, params

    halt 401 unless client

    token = JWT.encode({}, ENV['JWT_SECRET'], 'HS256')
    status 200
    { access_token: token, expires_in: 3_600, token_type: 'bearer' }.to_json
  end
end
