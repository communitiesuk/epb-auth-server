require "multi_json"
require "sinatra/base"

module Controller
  class BaseController < Sinatra::Base
    helpers do
      def container
        Container.new
      end

      def json_body
        JSON.parse request.body, symbolize_names: true
      rescue TypeError
        JSON.parse request.body.string, symbolize_names: true
      end

      def json_response(status, body = nil)
        content_type :json
        halt status, body.to_json
      end

      def authorize(scopes: nil)
        env[:token] = Auth::Sinatra::Conditional.process_request env

        if !scopes.nil? && !env[:token].scopes?(scopes)
          raise Boundary::NotAuthorizedError
        end
      rescue Auth::Errors::Error
        raise Boundary::NotAuthenticatedError
      end
    end

    error Boundary::NotAuthenticatedError do |_error|
      json_response 401,
                    code: "NOT_AUTHENTICATED"
    end

    error Boundary::NotAuthorizedError do |_error|
      json_response 403,
                    code: "NOT_AUTHORIZED"
    end

    error Boundary::NotFoundError do |_error|
      json_response 404,
                    code: "NOT_FOUND"
    end

    error Boundary::ValidationError do |error|
      json_response 422,
                    code: "VALIDATION_ERROR",
                    errors: error.errors
    end

    def self.prefix_route(route)
      return ENV["URL_PREFIX"] + route if ENV["URL_PREFIX"]

      route
    end
  end
end
