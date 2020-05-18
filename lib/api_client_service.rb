# frozen_string_literal: true

class ApiClientService < BaseService
  post "", jwt_auth: [] do
    container = Container.new
    body = json_body
    scopes = body["scopes"].nil? ? [] : body["scopes"]
    supplemental = body["supplemental"].nil? ? {} : body["supplemental"]

    client = container.create_new_client_use_case.execute body["name"],
                                                          scopes,
                                                          supplemental

    content_type :json
    status 201

    {
      data: { client: client.to_hash.merge(secret: client.secret) },
      meta: {},
    }.to_json
  end
end
