# frozen_string_literal: true

require "epb-auth-tools"

class Router
  def self.generate_routes
    routes = {
      "/" => Service::AuthService.new,
      "/api/client" => Service::ApiClientService.new,
      "/oauth/token" => Service::OAuthTokenService.new,
    }

    if ENV["APP_ENV"].nil? || ENV["APP_ENV"] == "development" ||
        ENV["APP_ENV"] == "test"
      routes["/oauth/test"] = Service::OAuthTokenTestService.new
    end

    route_prefix = ENV["URL_PREFIX"]
    route_prefix ||= ""

    routes.transform_keys { |uri| route_prefix + uri }
  end
end
