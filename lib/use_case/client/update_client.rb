module UseCase
  module Client
    class UpdateClient < UseCase::BaseUseCase
      def execute(id, name, scopes, supplemental)
        client = @container.client_gateway.fetch id: id

        raise Boundary::NotFoundError unless client

        @container.validation_helper.validate(
          { name: %w[not_empty] },
          client.to_hash,
        )

        client.name = name
        client.scopes = scopes
        client.supplemental = supplemental

        @container.client_gateway.update client
      end
    end
  end
end
