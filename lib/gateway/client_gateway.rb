require "sinatra/activerecord"

module Gateway
  class ClientGateway
    module Model
      class Client < ActiveRecord::Base
        validates_presence_of :name, :secret
        has_many :client_scopes, dependent: :delete_all
        accepts_nested_attributes_for :client_scopes, allow_destroy: true
      end

      class ClientScope < ActiveRecord::Base
        validates_presence_of :client, :scope
        belongs_to :client
      end
    end

    def create(name:, scopes: [], supplemental: {})
      scopes = scopes.map { |scope| { scope: scope } }

      ActiveRecord::Base.transaction do
        model =
          Model::Client.create! name: name,
                                secret: SecureRandom.alphanumeric(64),
                                supplemental: supplemental,
                                client_scopes_attributes: scopes.to_a

        model = Model::Client.find_by! id: model.id

        Domain::Client.new id: model.id,
                           name: model.name,
                           secret: model.secret,
                           scopes: model.client_scopes.map(&:scope),
                           supplemental: model.supplemental
      end
    end

    def fetch(attributes)
      model = Model::Client.find_by(attributes)

      unless model.nil?
        Domain::Client.new id: model.id,
                           name: model.name,
                           scopes: model.client_scopes.map(&:scope),
                           supplemental: model.supplemental
      end
    end

    def update(client)
      ActiveRecord::Base.transaction do
        model = Model::Client.find_by(client.to_hash.slice(:id))

        removed_scopes =
          model.client_scopes.filter do |scope|
            !client.scopes.include? scope.scope
          end

        removed_scopes = removed_scopes.map do |scope|
          { id: scope.id, _destroy: true }
        end

        new_scopes =
          client.scopes - model_scopes_to_client_scopes(model.client_scopes)

        model.update! client.to_hash.slice(:name).merge(
          client_scopes_attributes:
            client_scopes_to_model_scopes(new_scopes) + removed_scopes,
        )

        fetch id: client.id
      end
    end

  private

    def model_scopes_to_client_scopes(scopes)
      scopes.map(&:scope).to_a
    end

    def client_scopes_to_model_scopes(scopes)
      scopes.map { |scope| { scope: scope } }.to_a
    end
  end
end
