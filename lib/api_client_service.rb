# frozen_string_literal: true

require 'sinatra/base'

class ApiClientService < Sinatra::Base
  set(:jwt_auth) do
    condition do
      Auth::Sinatra::Conditional.process_request env
    rescue Auth::Errors::Error => e
      content_type :json
      halt 401, { error: e }.to_json
    end
  end

  post '', jwt_auth: [] do
    puts params[:name]

    client = Client.create params[:name]

    content_type :json
    status 201
    client.to_json
  end
end
