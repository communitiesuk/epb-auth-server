require "multi_json"
require "sinatra/base"
require "sinatra/custom_logger"

module Controller
  class BaseController < Sinatra::Base
    helpers Sinatra::CustomLogger

    set :logger, Logger.new($stdout, level: Logger::DEBUG)
    set :dump_errors, false

    configure :development do
      set :host_authorization, { permitted_hosts: [] }
      set :dump_errors, true
      set :show_exceptions, false
    end

    def self.prefix_route(route)
      return ENV["URL_PREFIX"] + route if ENV["URL_PREFIX"]

      route
    end

    configure :test do
      logger.level = Logger::FATAL
    end

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

    error do |exception|
      error = error_details(exception)
      logger.error JSON.generate(error)
      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)

      if settings.environment == :development
        json_response(500, error)
      else
        status 500
        "SERVER ERROR"
      end
    end

  private

    def error_details(exception)
      {
        type: exception.class.name,
        message: exception.message,
        backtrace: exception&.backtrace&.select { it.start_with?(File.expand_path("..", __dir__)) },
        cause: exception.cause && error_details(exception.cause),
      }.compact
    end
  end
end
