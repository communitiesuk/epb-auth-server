require "sentry-ruby"
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

use Rack::Attack
require_relative "./config/rack_attack_config"

environment = ENV["STAGE"]

unless %w[development test].include?(environment)
  Sentry.init do |config|
    config.environment = environment
    config.traces_sampler = lambda do |sampling_context|
      # if this is the continuation of a trace, just use that decision (rate controlled by the caller)
      !!sampling_context[:parent_sampled]
    end
  end
  use Sentry::Rack::CaptureExceptions
end

run Service.new
