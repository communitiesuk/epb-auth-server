class Service < Controller::BaseController
  get prefix_route("/") do
    status 200
    { links: "" }.to_json
  end

  get prefix_route("/healthcheck") do
    status 200
    { message: "ok" }.to_json
  end

  use Controller::ApiClientController
  use Controller::OAuthTokenController
  use Controller::OAuthTokenTestController
end
