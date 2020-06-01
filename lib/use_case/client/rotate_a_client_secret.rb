module UseCase
  module Client
    class RotateAClientSecret < UseCase::BaseUseCase
      def execute(client_id)
        client = @container.client_gateway.fetch id: client_id

        raise Boundary::NotFoundError unless client

        client.secret = @container.client_gateway.create_secret client

        client
      end
    end
  end
end
