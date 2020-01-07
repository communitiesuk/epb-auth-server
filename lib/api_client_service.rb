# frozen_string_literal: true

class ApiClientService < BaseService
  post '', jwt_auth: [] do
    client = Client.create json_body['name']

    content_type :json
    status 201
    client.to_json
  end
end
