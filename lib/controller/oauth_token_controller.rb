require "epb-auth-tools"

module Controller
  class OAuthTokenController < BaseController
    TOKEN_EXPIRY_IN_SECONDS = (30 * 60)

    post prefix_route("/oauth/token") do
      content_type :json
      container = Container.new
      auth_token = env.fetch("HTTP_AUTHORIZATION", "")

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

      token = Auth::Token.new iss: ENV["JWT_ISSUER"],
                              sub: client.id,
                              iat: Time.now.to_i,
                              exp: Time.now.to_i + TOKEN_EXPIRY_IN_SECONDS,
                              scopes: client.scopes,
                              sup: client.supplemental

      status 200
      {
        access_token: token.encode(ENV["JWT_SECRET"]),
        expires_in: TOKEN_EXPIRY_IN_SECONDS,
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
  end
end
