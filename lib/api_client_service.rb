# frozen_string_literal: true

class ApiClientService < BaseService
  post '', jwt_auth: [] do
    body = json_body
    scopes = body['scopes'].nil? ? [] : body['scopes']
    supplemental = body['supplemental'].nil? ? {} : body['supplemental']

    client =
      Gateway::ClientGateway.new.create name: body['name'],
                                        scopes: scopes,
                                        supplemental: supplemental

    content_type :json
    status 201

    response = {
      data: { client: client.to_hash.merge(secret: client.secret) }, meta: {}
    }

    # Temporary until schemes have updated to use new schema
    client.to_hash.merge(response).merge(secret: client.secret).to_json
  end
end
