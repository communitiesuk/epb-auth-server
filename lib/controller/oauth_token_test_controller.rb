module Controller
  class OAuthTokenTestController < BaseController
    get prefix_route("/oauth/token/test"), jwt_auth: [] do
      content_type :json
      { message: "ok" }.to_json
    end
  end
end
