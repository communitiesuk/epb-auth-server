# frozen_string_literal: true

require 'base64'
require 'securerandom'
require 'sinatra/activerecord'
require 'uuid'

class Client
  attr_reader :client_id

  class Client < ActiveRecord::Base
    validates_presence_of :name, :secret
    has_many :client_scope, dependent: :delete_all
  end

  class ClientScope < ActiveRecord::Base
    validates_presence_of :client_id, :scope
    belongs_to :client
  end

  def initialize(client_name, client_id)
    @client_name = client_name
    @client_id = client_id
  end

  def self.create(name, scopes = [])
    client = Client.create(name: name, secret: SecureRandom.alphanumeric(64))
    client.save!

    scopes.each { |scope| client.client_scope.create(scope: scope).save! }

    {
      name: client['name'],
      id: client['id'],
      secret: client['secret'],
      scopes: client.client_scope.map { |scope| scope['scope'] }.uniq
    }
  end

  def self.by_id(id)
    return nil if UUID.validate(client_id).nil?

    self::Client.find(id)
  rescue ActiveRecordError::RecordNotFound
    nil
  end

  def self.resolve_from_request(env, params)
    client_id, client_secret = get_credentials_from_request env, params

    return nil if UUID.validate(client_id).nil?

    client = self::Client.find(client_id)

    new client[:name], client[:id] if client[:secret] == client_secret
  rescue ActiveRecordError::RecordNotFound
    nil
  end

  def self.get_credentials_from_request(env, params)
    auth_token = env.fetch('HTTP_AUTHORIZATION', '')

    if auth_token.include? 'Basic'
      auth_token = auth_token.slice(6..-1)

      auth_token = Base64.decode64(auth_token)

      return auth_token.split(':', 2)
    end

    [params[:client_id], params[:client_secret]]
  end
end
