ENV["RACK_ENV"] = "test"
ENV["APP_ENV"] = "test"
ENV["RAILS_ENV"] = "test"
ENV["STAGE"] = "test"
ENV["DATABASE_URL"] ||= "postgresql://postgres:postgres@127.0.0.1/auth_test"
ENV["JWT_SECRET"] = "TestingSecretString"
ENV["JWT_ISSUER"] = "test.auth"
ENV["PERMANENTLY_BANNED_IP_ADDRESSES"] = '[{"reason":"did a bad thing", "ip_address": "198.51.100.100"},{"reason":"did another bad thing", "ip_address": "198.53.120.110"}]'

require "epb-auth-tools"
require "faker"
require "rack/attack"
require "rack/test"
require "rake"
require "rspec"
require "active_support"
require "active_support/core_ext"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"
require "timecop"
require "uuid"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../lib/")
loader.inflector.inflect "oauth_token_controller" => "OAuthTokenController"
loader.inflector.inflect "oauth_token_test_controller" => "OAuthTokenTestController"

loader.setup

module RSpecMixin
  def app
    Rack::Builder.new do
      use Rack::Attack
      require_relative "../config/rack_attack_config"
      run Service
    end
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
    header "Authorization", "Basic #{Base64.encode64([client_id, client_secret].join(':'))}"
    response = post "/oauth/token"

    MockedResponse.new body: JSON.parse(response.body, symbolize_names: true),
                       status: response.status
  end

  def make_request(token = nil)
    if token
      header "Authorization", "Bearer #{token.encode(ENV['JWT_SECRET'])}"
    end

    response = yield

    MockedResponse.new body: JSON.parse(response.body, symbolize_names: true),
                       status: response.status
  end

  def find_client_secret(client_id, secret)
    sql = "SELECT *
         FROM client_secrets
         WHERE client_id = $1 AND secret = crypt($2, secret)"

    binds = [
      ActiveRecord::Relation::QueryAttribute.new(
        "client_id",
        client_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "secret",
        secret,
        ActiveRecord::Type::String.new,
      ),
    ]
    ActiveRecord::Base.connection.exec_query(sql, "SQL", binds)
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

  config.before do
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
