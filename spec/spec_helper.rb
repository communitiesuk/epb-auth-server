ENV["RACK_ENV"] = "test"
ENV["APP_ENV"] = "test"
ENV["RAILS_ENV"] = "test"
ENV["DATABASE_URL"] ||= "postgresql://postgres:postgres@127.0.0.1/auth_test"
ENV["JWT_SECRET"] = "TestingSecretString"
ENV["JWT_ISSUER"] = "test.auth"

require "epb-auth-tools"
require "faker"
require "rack/test"
require "rake"
require "rspec"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"
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

  def container
    Container.new
  end

  def create_user(name: nil, email: nil, password: nil)
    name = Faker::Name.unique.name if name.nil?
    email = Faker::Internet.unique.email if email.nil?
    password = Faker::Alphanumeric.alpha number: 16 if password.nil?

    Gateway::UserGateway.new.create email: email,
                                    name: name,
                                    password: password
  end

  def create_client(name: nil, supplemental: {}, scopes: [])
    if name.nil?
      name = Faker::Company.name
    end

    Gateway::ClientGateway.new.create name: name,
                                      scopes: scopes,
                                      supplemental: supplemental
  end

  def client_token(client)
    create_token id: client.id,
                 scopes: client.scopes,
                 supplemental: client.supplemental
  end

  def create_token(id: nil, scopes: [], supplemental: {})
    Auth::Token.new iss: ENV["JWT_ISSUER"],
                    sub: id,
                    iat: Time.now.to_i,
                    exp: Time.now.to_i + (60 * 60),
                    scopes: scopes,
                    supplemental: supplemental
  end

  def request_token(client_id, client_secret)
    header "Authorization", "Basic " + Base64.encode64([client_id, client_secret].join(":"))
    response = post "/oauth/token"

    MockedResponse.new body: JSON.parse(response.body, symbolize_names: true),
                       status: response.status
  end

  def make_request(token = nil, &block)
    if token
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
    end

    response = block.call

    MockedResponse.new body: JSON.parse(response.body, symbolize_names: true),
                       status: response.status
  end

  class MockedResponse
    attr_reader :body, :status

    def initialize(body:, status:)
      @body = body
      @status = status
    end

    def get(path)
      @body.dig(*path)
    end
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Rack::Test::Methods

  config.before(:each) do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
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
