module UseCase
  module Client
    class UpdateClient
      class ClientNotFoundError < StandardError; end

      def initialize(container)
        @container = container
      end

      def execute(id, name, scopes, supplemental)
        client = @container.client_gateway.fetch id: id

        raise ClientNotFoundError unless client

        client.name = name
        client.scopes = scopes
        client.supplemental = supplemental

        @container.client_gateway.update client
      end
    end
  end
end
