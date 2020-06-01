module Controller
  class OAuthTokenTestController < BaseController
    get prefix_route("/oauth/token/test") do
      authorize

      json_response 200,
                    {
                      data: {
                        subject: env[:token].sub,
                      },
                    }
    end
  end
end
