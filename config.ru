require "active_support"
require "active_support/cache"
require "active_support/notifications"
require "sentry-ruby"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

environment = ENV["STAGE"]

unless %w[development test].include?(environment)

  Sentry.init do |config|
    config.environment = environment
    config.before_send = lambda do |event, hint|
      if hint[:exception].is_a?(Boundary::Error)
        nil
      else
        event
      end
    end
    config.traces_sampler = lambda do |sampling_context|
      # if this is the continuation of a trace, just use that decision (rate controlled by the caller)
      !!sampling_context[:parent_sampled]
    end
  end
  use Sentry::Rack::CaptureExceptions
end

run Service.new
