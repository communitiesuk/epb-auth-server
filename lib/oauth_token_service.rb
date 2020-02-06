# frozen_string_literal: true

class OAuthTokenService < BaseService
  post '' do
    content_type :json
    client = Client.resolve_from_request env, params

    unless client
      halt 401, { error: 'Could not resolve client from request' }.to_json
    end

    token =
      Auth::Token.new(
        iss: ENV['JWT_ISSUER'],
        sub: client.client_id,
        iat: Time.now.to_i,
        scopes: client.scopes,
        sup: client.supplemental
      )

    status 200
    {
      access_token: token.encode(ENV['JWT_SECRET']),
      expires_in: 3_600,
      token_type: 'bearer'
    }.to_json
  end
end
