# frozen_string_literal: true

require 'multi_json'
require 'sinatra/base'

class BaseService < Sinatra::Base
  helpers do
    def json_body
      ::MultiJson.decode(request.body)
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
