# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.inflector.inflect 'oauth_token_service' => 'OAuthTokenService'

loader.setup

module RSpecMixin
  def app
    Rack::URLMap.new(
      '/' => AuthService.new,
      '/oauth/token' => OAuthTokenService.new
    )
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Rack::Test::Methods
end
