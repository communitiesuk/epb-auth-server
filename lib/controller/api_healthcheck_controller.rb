module Controller
  class ApiHealthcheckController < BaseController
    get prefix_route("/healthcheck") do
      json_response 200,
                    message: "ok"
    end
  end
end
