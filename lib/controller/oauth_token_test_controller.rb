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
