# frozen_string_literal: true

module Controller
  class ApiClientController < BaseController
    get prefix_route("/api/client/:clientId"), jwt_auth: %w[client:fetch] do
      content_type :json
      container = Container.new

      client = container.get_client_from_id_use_case.execute params["clientId"]

      unless client
        halt 404,
             {
               error: "Could not find client #{params['clientId']}",
             }.to_json
      end

      status 200
      {
        data: { client: client.to_hash },
        meta: {},
      }.to_json
    end

    post prefix_route("/api/client"), jwt_auth: %w[client:create] do
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

    put prefix_route("/api/client/:clientId"), jwt_auth: %w[client:update] do
      container = Container.new

      client = container.get_client_from_id_use_case.execute params["clientId"]

      unless client
        halt 404,
             {
               error: "Could not find client #{params['clientId']}",
             }.to_json
      end

      client.name = json_body["name"]
      client.scopes = json_body["scopes"]
      client.supplemental = json_body["supplemental"]

      client = container.update_client_use_case.execute client.id,
                                                        client.name,
                                                        client.scopes,
                                                        client.supplemental

      status 200
      {
        data: { client: client.to_hash },
        meta: {},
      }.to_json
    end

    delete prefix_route("/api/client/:clientId"), jwt_auth: %w[client:delete] do
      container = Container.new

      client = container.get_client_from_id_use_case.execute params["clientId"]

      unless client
        halt 404,
             {
               error: "Could not find client #{params['clientId']}",
             }.to_json
      end

      container.delete_client_use_case.execute client.id

      status 200
      {
        data: {},
        meta: {
          action: [{
            client_id: params["clientId"],
            deleted: true,
          }],
        },
      }.to_json
    end

    post prefix_route("/api/client/:clientId/rotate-secret"), jwt_auth: [] do
      container = Container.new

      auth_token = env[:jwt_auth]

      if params["clientId"] != auth_token.sub
        halt 403,
             {
               error: sprintf(
                 "Your client (%s) does not have permission to update client %s",
                 auth_token.sub,
                 params["clientId"],
               ),
             }.to_json
      end

      client = container.rotate_a_client_secret_use_case.execute params["clientId"]

      status 200
      {
        data: { client: client.to_hash.merge(secret: client.secret) },
        meta: {},
      }.to_json
    rescue StandardError
      halt 404,
           {
             error: "Could not find client #{params['clientId']}",
           }.to_json
    end
  end
end