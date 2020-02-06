# frozen_string_literal: true

require 'base64'
require 'securerandom'
require 'sinatra/activerecord'
require 'uuid'

class Client
  attr_reader :client_id, :scopes, :supplemental

  class Client < ActiveRecord::Base
    validates_presence_of :name, :secret
    has_many :client_scope, dependent: :delete_all
  end

  class ClientScope < ActiveRecord::Base
    validates_presence_of :client_id, :scope
    belongs_to :client
  end

  def initialize(client_name, client_id, scopes = [], supplemental = {})
    @client_name = client_name
    @client_id = client_id
    @scopes = scopes.empty? ? [] : scopes
    @supplemental = supplemental
  end

  def self.create(name, scopes = [], supplemental)
    client = Client.create(name: name, secret: SecureRandom.alphanumeric(64), supplemental: supplemental)
    client.save!

    scopes.each { |scope| client.client_scope.create(scope: scope).save! }

    {
      name: client['name'],
      id: client['id'],
      secret: client['secret'],
      scopes: client.client_scope.map { |scope| scope['scope'] }.uniq,
      supplemental: client['supplemental']
    }
  end

  def self.by_id(id)
    return nil if UUID.validate(id).nil?

    self::Client.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.resolve_from_request(env, params)
    client_id, client_secret = get_credentials_from_request env, params

    return nil if UUID.validate(client_id).nil?

    client = by_id(client_id)

    if client[:secret] == client_secret
      new client[:name],
          client[:id],
          client.client_scope.map { |scope| scope['scope'] }.uniq,
          client[:supplemental]
    end
  rescue ActiveRecord::RecordNotFound
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
