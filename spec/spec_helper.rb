# frozen_string_literal: true

require 'epb-auth-tools'
require 'rack/test'
require 'rspec'
require 'uuid'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.inflector.inflect 'oauth_token_service' => 'OAuthTokenService'
loader.inflector.inflect 'oauth_token_test_service' => 'OAuthTokenTestService'

loader.setup

ENV['RACK_ENV'] = ENV['APP_ENV'] = 'test'
ENV['JWT_SECRET'] = 'TestingSecretString'
ENV['JWT_ISSUER'] = 'test.auth'

module RSpecMixin
  def app
    Rack::URLMap.new(Router.generate_routes)
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Rack::Test::Methods

  config.before(:each) do
    Gateway::ClientGateway::Model::Client.destroy_all
    client =
      Gateway::ClientGateway::Model::Client.create(
        id: '72d1d680-92ee-463a-98a8-f3e3973df038',
        name: 'test-client',
        secret: 'test-client-secret',
        supplemental: { test: [true] }
      )
    client.client_scopes.create(scope: 'scope:one')
    client.client_scopes.create(scope: 'scope:two')

    Gateway::ClientGateway::Model::Client.create(
      id: '54d1d680-92ee-463a-98a8-f3e3973df038',
      name: 'test-client-two',
      secret: 'test-client-secret-with-:-in-it'
    )
  end
end

RSpec::Matchers.define :be_a_valid_jwt_token do
  match do |actual|
    processor = Auth::TokenProcessor.new ENV['JWT_SECRET'], ENV['JWT_ISSUER']
    _token = processor.process actual
    true
  rescue StandardError
    false
  end
end

RSpec::Matchers.define :be_a_valid_uuid do
  match { |actual| !UUID.validate(actual).nil? }
end
