# frozen_string_literal: true

class ApiClientService < BaseService
  post '', jwt_auth: [] do
    body = json_body
    scopes = body['scopes'].nil? ? [] : body['scopes']
    supplemental = body['supplemental'].nil? ? {} : body['supplemental']

    client = Client.create body['name'], scopes, supplemental

    content_type :json
    status 201
    client.to_json
  end
end
