# frozen_string_literal: true

require 'jwt'
require 'sinatra/base'

class OAuthTokenService < Sinatra::Base
  post '' do
    content_type :json
    client = Client.resolve_from_request env, params

    halt 401 unless client

    token =
      Auth::Token.new(
        iss: ENV['JWT_ISSUER'], sub: client.client_id, iat: Time.now.to_i
      )

    status 200
    {
      access_token: token.encode(ENV['JWT_SECRET']),
      expires_in: 3_600,
      token_type: 'bearer'
    }.to_json
  end
end
