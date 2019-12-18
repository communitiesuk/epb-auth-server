# frozen_string_literal: true

require 'epb_auth_tools'
require 'sinatra/base'

class OAuthTokenTestService < Sinatra::Base
  set(:jwt_auth) do
    condition do
      Auth::Sinatra::Conditional.process_request env
    rescue Auth::Errors::Error => e
      content_type :json
      halt 401, { error: e }.to_json
    end
  end

  get '', jwt_auth: [] do
    content_type :json
    { message: 'ok' }.to_json
  end
end
