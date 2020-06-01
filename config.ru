require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

run Service.new
