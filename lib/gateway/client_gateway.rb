require "sinatra/activerecord"
require "acts_as_paranoid"

module Gateway
  class ClientGateway
    module Model
      class Client < ActiveRecord::Base
        validates_presence_of :name
        has_many :client_scopes, dependent: :delete_all
        has_many :client_secrets, dependent: :delete_all
        accepts_nested_attributes_for :client_scopes, allow_destroy: true
        acts_as_paranoid
      end

      class ClientScope < ActiveRecord::Base
        validates_presence_of :client, :scope
        belongs_to :client
        acts_as_paranoid
      end

      class ClientSecret < ActiveRecord::Base
        validates_presence_of :client, :secret
        belongs_to :client
      end
    end

    def create(name:, scopes: [], supplemental: {})
      scopes = scopes.map { |scope| { scope: scope } }

      ActiveRecord::Base.transaction do
        model =
          Model::Client.create! name: name,
                                supplemental: supplemental,
                                client_scopes_attributes: scopes.to_a

        model_to_client(Model::Client.find_by!(id: model.id), create_secret(model))
      end
    end

    def create_secret(client, secret = nil)
      secret = SecureRandom.alphanumeric(64) if secret.nil?

      sql = "INSERT INTO client_secrets (client_id, secret)
             VALUES ($1, crypt($2, gen_salt('bf')))"

      binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "client_id",
          client.id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "secret",
          secret,
          ActiveRecord::Type::String.new,
        ),
      ]

      Model::ClientSecret.connection.exec_query sql, "SQL", binds

      secret
    end

    def authenticate_secret(client_id, secret)
      sql = "SELECT bool_or(secret = crypt($2, secret)) AS authenticated
             FROM client_secrets
             WHERE client_id = $1
             GROUP BY client_id"

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

      results = ActiveRecord::Base.connection.exec_query sql, "SQL", binds

      results[0] && results[0]["authenticated"]
    end

    def fetch(attributes)
      model_to_client(Model::Client.find_by(attributes))
    end

    def update(client)
      ActiveRecord::Base.transaction do
        model = Model::Client.find_by(client.to_hash.slice(:id))

        model.supplemental = client.supplemental

        removed_scopes = if client.scopes.empty?
                           model.client_scopes
                         else
                           model.client_scopes.filter do |scope|
                             !client.scopes.include? scope.scope
                           end
                         end

        removed_scopes = removed_scopes.map do |scope|
          { id: scope.id, _destroy: true }
        end

        new_scopes =
          client.scopes - model_scopes_to_client_scopes(model.client_scopes)

        model.update! client.to_hash.slice(:name, :supplemental).merge(
          client_scopes_attributes:
              client_scopes_to_model_scopes(new_scopes) + removed_scopes,
        )

        fetch id: client.id
      end
    end

    def delete(client)
      ActiveRecord::Base.transaction do
        model = Model::Client.find_by(client.to_hash.slice(:id))

        model.destroy!

        !model.deleted_at.nil?
      end
    end

    def update_client_secret_last_used_at(client_id, secret)
      sql = "UPDATE client_secrets
             SET last_used_at = $1
             WHERE client_id = $2 AND secret = crypt($3, secret)"

      binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "last_used_at",
          DateTime.now,
          ActiveRecord::Type::Time.new,
        ),
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

      ActiveRecord::Base.connection.exec_query sql, "SQL", binds
    end

    def update_client_secret_superseded_at(client_id, time)
      last_used_client_secret = Model::Client.find(client_id).client_secrets.order(:last_used_at).first

      last_used_client_secret.update(superceded_at: time)
    end

  private

    def model_scopes_to_client_scopes(scopes)
      scopes.map(&:scope).to_a
    end

    def client_scopes_to_model_scopes(scopes)
      scopes.map { |scope| { scope: scope } }.to_a
    end

    def model_to_client(model = nil, secret = nil)
      return nil unless model

      client = {
        id: model.id,
        name: model.name,
        secret: secret,
        scopes: model.client_scopes.map(&:scope),
        supplemental: JSON.parse(model.supplemental.to_json, symbolize_names: true),
      }

      client = client.merge secret: secret if secret

      Domain::Client.new client
    end
  end
end
