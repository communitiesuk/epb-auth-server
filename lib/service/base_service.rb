# frozen_string_literal: true

require "multi_json"
require "sinatra/base"

module Service
  class BaseService < Sinatra::Base
    helpers do
      def json_body
        ::MultiJson.decode(request.body)
      end

      def json_params
        ::MultiJson.decode(params)
      end

      def json_request
        ::MultiJson.decode(params.merge(request.body))
      end
    end

    set(:jwt_auth) do
      condition do
        Auth::Sinatra::Conditional.process_request env
      rescue Auth::Errors::Error => e
        content_type :json
        halt 401, { error: e }.to_json
      end
    end
  end
end
