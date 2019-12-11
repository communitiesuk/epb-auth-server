# frozen_string_literal: true

require 'sinatra/base'

class OAuthTokenService < Sinatra::Base
  post '' do
    status 200
    { access_token: 'token', expires_in: 3_600 }.to_json
  end
end
