class Service < Controller::BaseController
  use Controller::ApiRootController
  use Controller::ApiHealthcheckController
  use Controller::ApiClientController
  use Controller::ApiUserController
  use Controller::OAuthTokenController
  use Controller::OAuthTokenTestController
end
