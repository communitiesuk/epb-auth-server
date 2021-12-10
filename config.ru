require "sentry-ruby"
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

environment = ENV["STAGE"]

unless %w[development test].include?(environment)
  Sentry.init do |config|
    config.environment = environment
  end
  use Sentry::Rack::CaptureExceptions
end

run Service.new
