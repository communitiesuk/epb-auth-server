module UseCase
  module Client
    class RotateAClientSecret < UseCase::BaseUseCase
      def execute(client_id)
        client = @container.client_gateway.fetch id: client_id

        raise Boundary::NotFoundError unless client

        @container.client_gateway.update_client_secret_superseded_at(client_id, Time.now + 1.day)

        client.secret = @container.client_gateway.create_secret client

        client
      end
    end
  end
end
