# frozen_string_literal: true

require 'sinatra/base'

class AuthService < Sinatra::Base
  get '/' do
    status 200
    { links: '' }.to_json
  end

  get '/healthcheck' do
    status 200
    { message: 'ok' }.to_json
  end
end
