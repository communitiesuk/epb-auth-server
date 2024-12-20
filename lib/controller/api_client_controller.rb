require "json-schema"
require "sinatra/activerecord"

module Controller
  class ApiClientController < BaseController
    POST_SCHEMA = {
      type: "object",
      required: %w[name],
      properties: {
        name: {
          type: "string",
        },
        scopes: {
          type: %w[array null],
        },
        supplemental: {
          type: %w[object null],
          properties: {
            owner: {
              type: %w[string null],
            },
            scheme_ids: {
              type: %w[array null],
            },
          },
        },
      },
    }.freeze

    PUT_SCHEMA = {
      type: "object",
      required: %w[id name scopes],
      properties: {
        id: {
          type: "string",
        },
        name: {
          type: "string",
        },
        scopes: {
          type: "array",
        },
        supplemental: {
          type: %w[object null],
          properties: {
            owner: {
              type: %w[string null],
            },
            scheme_ids: {
              type: %w[array null],
            },
          },
        },
      },
    }.freeze

    PATCH_SCHEMA = {
      type: "object",
      required: %w[op scopes],
      properties: {
        op: {
          "type": "string",
          "pattern": "(?:add|remove)",
        },
        scopes: {
          type: "array",
        },
      },
    }.freeze

    get prefix_route("/api/client/:clientId") do
      authorize scopes: %w[client:fetch]

      client = container.get_client_from_id_use_case.execute params["clientId"]

      raise Boundary::NotFoundError unless client

      json_response 200,
                    data: { client: client.to_hash },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    post prefix_route("/api/client") do
      authorize scopes: %w[client:create]

      client = request_body(POST_SCHEMA)

      client = container.create_new_client_use_case.execute(client[:name],
                                                            client[:scopes],
                                                            client[:supplemental])

      json_response 201,
                    data: { client: client.to_hash.merge(secret: client.secret) },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Json::ParseError
        error_response(400, "INVALID_REQUEST", e.message)
      when Boundary::Json::ValidationError
        error_response(422, "INVALID_REQUEST", e.message)
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    put prefix_route("/api/client/:clientId") do
      authorize scopes: %w[client:update]

      client = request_body(PUT_SCHEMA)

      raise Boundary::NotFoundError unless client

      client = container.update_client_use_case.execute client[:id],
                                                        client[:name],
                                                        client[:scopes],
                                                        client[:supplemental]

      json_response 200,
                    data: { client: },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Json::ParseError
        error_response(400, "INVALID_REQUEST", e.message)
      when Boundary::Json::ValidationError
        error_response(422, "INVALID_REQUEST", e.message)
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    patch prefix_route("/api/client/:clientId") do
      authorize scopes: %w[client:update]

      client = request_body(PATCH_SCHEMA)

      raise Boundary::NotFoundError unless client

      client = container.update_client_use_case.execute_patch params["clientId"],
                                                              client[:op],
                                                              client[:scopes]

      json_response 200,
                    data: { client: },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Json::ParseError
        error_response(400, "INVALID_REQUEST", e.message)
      when Boundary::Json::ValidationError
        error_response(422, "INVALID_REQUEST", e.message)
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    delete prefix_route("/api/client/:clientId") do
      authorize scopes: %w[client:delete]

      client = container.get_client_from_id_use_case.execute params["clientId"]

      raise Boundary::NotFoundError unless client

      container.delete_client_use_case.execute client.id

      json_response 200
    rescue StandardError => e
      case e
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    post prefix_route("/api/client/:clientId/rotate-secret") do
      authorize

      if params["clientId"] != env[:token].sub
        halt 403,
             {
               error: sprintf(
                 "Your client (%s) does not have permission to update client %s",
                 env[:token].sub,
                 params["clientId"],
               ),
             }.to_json
      end

      client = container.rotate_a_client_secret_use_case.execute params["clientId"]

      json_response 200,
                    data: { client: client.to_hash.merge(secret: client.secret) },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Error
        raise
      else
        server_error e
      end
    end
  end
end
