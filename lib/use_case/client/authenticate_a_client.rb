module UseCase
  module Client
    class AuthenticateAClient < UseCase::BaseUseCase
      def execute(id, secret)
        gateway = @container.client_gateway

        client = gateway.fetch(id:)

        gateway.update_client_secret_last_used_at(id, secret) if client

        client if client && gateway.authenticate_secret(client.id, secret)
      end
    end
  end
end
