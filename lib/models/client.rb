# frozen_string_literal: true

require 'base64'

class Client
  @test_clients = [
    {
      name: 'test-client',
      id: 'test-client-id',
      secret: 'test-client-secret'
    }
  ]

  def initialize(client_name, client_id)
    @client_name = client_name
    @client_id = client_id
  end

  def self.resolve_from_request(env, params)
    client_id, client_secret = get_credentials_from_request env, params

    found = @test_clients.select do |client|
      client[:id] == client_id
    end

    client = found.first

    if client && client[:secret] == client_secret
      new client[:client_name], client[:client_id]
    end
  end

  def self.get_credentials_from_request(env, params)
    auth_token = env.fetch('HTTP_AUTHORIZATION', '')

    if auth_token.include? 'Basic'
      auth_token = auth_token.slice(6..-1)

      auth_token = Base64.decode64(auth_token)

      return auth_token.split(':')
    end

    [params[:client_id], params[:client_secret]]

  end
end
