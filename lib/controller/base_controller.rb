require "multi_json"
require "sinatra/base"
require "sinatra/cross_origin"

module Controller
  class BaseController < Sinatra::Base
    configure :development do
      set :host_authorization, { permitted_hosts: [] }
    end

    helpers do
      def container
        Container.new
      end

      def json_body
        if ENV["STAGE"] == "development"
          JSON.parse request.body.read, symbolize_names: true
        else
          JSON.parse request.body, symbolize_names: true
        end
      rescue TypeError
        JSON.parse request.body.string, symbolize_names: true
      end

      def json_response(status, body = nil)
        content_type :json
        halt status, body.to_json
      end

      def request_body(schema)
        container.json_helper.convert_to_ruby_hash(request.body.read.to_s, schema:)
      end

      def error_response(response_code, error_code, title)
        json_error_response({ errors: [{ code: error_code, title: }] }, response_code)
      end

      def json_error_response(object, code = 200)
        content_type :json
        status code

        ActiveRecord::Base.connection_handler.clear_active_connections!(:all)

        container.json_helper.convert_to_json(object)
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

    configure do
      enable :cross_origin
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

    error Sinatra::NotFound do
      json_response 404,
                    code: "NOT_FOUND"
    end

    def server_error(exception)
      Sentry.capture_exception(exception) if defined?(Sentry)

      message =
        exception.methods.include?(:message) ? exception.message : exception

      error = { type: exception.class.name, message: }

      if exception.methods.include? :backtrace
        error[:backtrace] = exception.backtrace
      end

      Logger.new($stdout, level: Logger::ERROR).error JSON.generate(error)

      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)

      json_response 500,
                    code: "SERVER_ERROR",
                    errors: exception
    end

    def self.prefix_route(route)
      return ENV["URL_PREFIX"] + route if ENV["URL_PREFIX"]

      route
    end
  end
end
