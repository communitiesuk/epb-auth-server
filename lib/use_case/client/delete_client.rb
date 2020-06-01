module UseCase
  module Client
    class DeleteClient < UseCase::BaseUseCase
      def execute(id)
        client = @container.client_gateway.fetch id: id

        raise Boundary::NotFoundError unless client

        @container.client_gateway.delete client
      end
    end
  end
end
