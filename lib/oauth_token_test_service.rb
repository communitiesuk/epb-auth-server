# frozen_string_literal: true

class OAuthTokenTestService < BaseService
  get '', jwt_auth: [] do
    content_type :json
    { message: 'ok' }.to_json
  end
end
