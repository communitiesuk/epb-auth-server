module UseCase
  module Client
    class GetClientFromId < UseCase::BaseUseCase
      def execute(id)
        client = @container.client_gateway.fetch(id:)

        raise Boundary::NotFoundError unless client

        client
      end
    end
  end
end
