# frozen_string_literal: true

require 'jwt'
require 'rspec'
require 'rack/test'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.push_dir("#{__dir__}/../lib/models/")
loader.inflector.inflect 'oauth_token_service' => 'OAuthTokenService'

loader.setup

ENV['JWT_SECRET'] = 'TestingSecretString'
ENV['JWT_ISSUER'] = 'test.auth'

module RSpecMixin
  def app
    Rack::URLMap.new(
      '/' => AuthService.new, '/oauth/token' => OAuthTokenService.new
    )
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Rack::Test::Methods
end

RSpec::Matchers.define :be_a_valid_jwt_token do
  match do |actual|
    options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }

    JWT.decode actual, ENV['JWT_SECRET'], true, options
    true
  rescue JWT::DecodeError
    false
  end
end
