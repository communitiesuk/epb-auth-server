# frozen_string_literal: true

class Router
  def self.generate_routes
    routes = {
      '/' => AuthService.new,
      '/api/client' => ApiClientService.new,
      '/oauth/token' => OAuthTokenService.new
    }

    if ENV['APP_ENV'].nil? || ENV['APP_ENV'] == 'development'
      routes['/oauth/test'] = OAuthTokenTestService.new
    end

    routes
  end
end
