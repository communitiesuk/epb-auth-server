# frozen_string_literal: true

ENV["RACK_ENV"] = "test"
ENV["APP_ENV"] = "test"
ENV["RAILS_ENV"] = "test"
ENV["DATABASE_URL"] = "postgresql://postgres:postgres@127.0.0.1/auth_test"
ENV["JWT_SECRET"] = "TestingSecretString"
ENV["JWT_ISSUER"] = "test.auth"

require "epb-auth-tools"
require "rack/test"
require "rspec"
require "sinatra/activerecord"
require "uuid"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

module RSpecMixin
  def app
    Service.new
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Rack::Test::Methods

  config.before(:each) do
    ActiveRecord::Base.connection.exec_query "DELETE FROM client_scopes"
    ActiveRecord::Base.connection.exec_query "DELETE FROM clients"

    client =
      Gateway::ClientGateway::Model::Client.create(
        id: "72d1d680-92ee-463a-98a8-f3e3973df038",
        name: "test-client",
        secret: "test-client-secret",
        supplemental: { test: [true] },
      )
    client.client_scopes.create(scope: "scope:one")
    client.client_scopes.create(scope: "scope:two")

    client =
      Gateway::ClientGateway::Model::Client.create(
        id: "93d1d680-92ee-463a-98a8-f3e3973df038",
        name: "test-delete-client",
        secret: "test-client-secret",
        supplemental: { test: [true] },
      )
    client.client_scopes.create(scope: "scope:one")
    client.client_scopes.create(scope: "scope:two")

    Gateway::ClientGateway::Model::Client.create(
      id: "54d1d680-92ee-463a-98a8-f3e3973df038",
      name: "test-client-two",
      secret: "test-client-secret-with-:-in-it",
    )
  end
end

RSpec::Matchers.define :be_a_valid_jwt_token do
  match do |actual|
    processor = Auth::TokenProcessor.new ENV["JWT_SECRET"], ENV["JWT_ISSUER"]
    _token = processor.process actual
    true
  rescue StandardError
    false
  end
end

RSpec::Matchers.define :be_a_valid_uuid do
  match { |actual| !UUID.validate(actual).nil? }
end
