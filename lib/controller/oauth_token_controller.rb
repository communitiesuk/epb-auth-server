require "epb-auth-tools"

module Controller
  class OAuthTokenController < BaseController
    ONE_HOUR_IN_SECONDS = (60 * 60)
    FIFTEEN_MINUTES_IN_SECONDS = (15 * 60)

    post prefix_route("/oauth/token") do
      content_type :json
      container = Container.new
      auth_token = env.fetch("HTTP_AUTHORIZATION", "")

      add_cors_headers

      client_id, client_secret =
        if auth_token.include? "Basic"
          Base64.decode64(auth_token.slice(6..-1)).split(":", 2)
        else
          [params[:client_id], params[:client_secret]]
        end

      client =
        container.authenticate_a_client.execute(
          client_id,
          client_secret,
        )

      unless client
        halt 401, { error: "Could not resolve client from request" }.to_json
      end

      token_expiry_length = (Helper::Toggles.enabled?("auth-server-fifteen-minute-jwt-expiry") ? FIFTEEN_MINUTES_IN_SECONDS : ONE_HOUR_IN_SECONDS)

      token = Auth::Token.new iss: ENV["JWT_ISSUER"],
                              sub: client.id,
                              iat: Time.now.to_i,
                              exp: Time.now.to_i + token_expiry_length,
                              scopes: client.scopes,
                              sup: client.supplemental

      status 200
      {
        access_token: token.encode(ENV["JWT_SECRET"]),
        expires_in: token_expiry_length,
        token_type: "bearer",
      }.to_json
    rescue StandardError => e
      case e
      when Boundary::Error
        raise
      else
        server_error e
      end
    end

    options prefix_route("/oauth/token") do
      add_cors_headers

      200
    end

  private

    def add_cors_headers
      unless ENV["EPB_API_DOCS_URL"].nil?
        response.headers["Access-Control-Allow-Origin"] = ENV["EPB_API_DOCS_URL"]
        response.headers["Vary"] = "Origin"
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Headers"] =
          "Content-Type, Cache-Control, Accept, Authorization, X-Requested-With"
      end
    end
  end
end
