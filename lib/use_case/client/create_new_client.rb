module UseCase
  module Client
    class CreateNewClient < UseCase::BaseUseCase
      def execute(name, scopes, supplemental)
        client = {
          name:,
          scopes: scopes.nil? ? [] : scopes,
          supplemental: supplemental.nil? ? {} : supplemental,
        }
        @container.validation_helper.validate({ name: %w[not_empty] }, client)
        @container.client_gateway.create(**client)
      end
    end
  end
end
