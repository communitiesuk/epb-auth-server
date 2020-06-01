module UseCase
  module Client
    class CreateNewClient < UseCase::BaseUseCase
      def execute(name: nil, scopes: [], supplemental: {})
        client = {
          name: name,
          scopes: scopes,
          supplemental: supplemental,
        }
        @container.validation_helper.validate({ name: %w[not_empty] }, client)
        @container.client_gateway.create client
      end
    end
  end
end
