# frozen_string_literal: true

module Service
  class AuthService < BaseService
    get "/" do
      status 200
      { links: "" }.to_json
    end

    get "/healthcheck" do
      status 200
      { message: "ok" }.to_json
    end
  end
end
