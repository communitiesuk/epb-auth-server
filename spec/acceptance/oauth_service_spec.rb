# frozen_string_literal: true

require 'base64'

describe OAuthTokenService do
  context 'requesting a new token with valid client credentials in the header' do
    client_id = 'a3c92627-7f59-4b1d-a2a0-7fbabdd8b06b'
    client_secret = 'y9)NAVxQSQ0<`[qdVMNzUmCk@*E*8?.z{(}+z|YW^D/ft1<.U!=U'

    auth_header = [Base64.encode64(client_id), Base64.encode64(client_secret)].join(':')

    let(:response) do
      post '/oauth/token',
           nil,
           'Authorization': 'Basic ' + auth_header
    end

    it 'gives a status of 200' do
      expect(response.status).to be 200
    end

    it 'gives a response with an access_token' do
      body = JSON.parse response.body

      expect(body['access_token']).to be_a String
    end

    it 'gives a response with a expires_at at least an hour in the future' do
      body = JSON.parse response.body

      expect(body['expires_at']).to be >= Time.now.to_i + 3600
    end
  end
end
