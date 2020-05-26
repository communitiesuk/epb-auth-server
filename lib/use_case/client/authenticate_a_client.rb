module UseCase
  module Client
    class AuthenticateAClient
      def initialize(container)
        @container = container
      end

      def execute(id, secret)
        gateway = @container.client_gateway

        client = gateway.fetch id: id

        client if client && gateway.authenticate_secret(client.id, secret)
      end
    end
  end
end
