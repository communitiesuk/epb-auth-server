# frozen_string_literal: true

require "epb-auth-tools"

module Controller
  class OAuthTokenController < BaseController
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
        container.get_client_from_id_and_secret_use_case.execute(
          client_id,
          client_secret,
        )

      unless client
        halt 401, { error: "Could not resolve client from request" }.to_json
      end

      token = Auth::Token.new iss: ENV["JWT_ISSUER"],
                              sub: client.id,
                              iat: Time.now.to_i,
                              exp: Time.now.to_i + (60 * 60),
                              scopes: client.scopes,
                              sup: client.supplemental

      status 200
      {
        access_token: token.encode(ENV["JWT_SECRET"]),
        expires_in: 3_600,
        token_type: "bearer",
      }.to_json
    end
  end
end
