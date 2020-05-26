module UseCase
  module Client
    class RotateAClientSecret
      class ClientNotFoundError < StandardError; end

      def initialize(container)
        @container = container
      end

      def execute(client_id)
        client = @container.client_gateway.fetch id: client_id

        raise ClientNotFoundError unless client

        client.secret = @container.client_gateway.create_secret client

        client
      end
    end
  end
end
