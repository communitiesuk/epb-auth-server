module UseCase
  module Client
    class UpdateClient < UseCase::BaseUseCase
      def execute(id, name, scopes, supplemental)
        client = @container.client_gateway.fetch(id:)

        raise Boundary::NotFoundError unless client

        @container.validation_helper.validate(
          { name: %w[not_empty] },
          client.to_hash,
        )

        client.name = name
        client.scopes = scopes
        client.supplemental = supplemental.nil? ? {} : supplemental

        @container.client_gateway.update client
      end

      def execute_patch(id, operator, updated_scopes)
        client = @container.client_gateway.fetch(id:)

        raise Boundary::NotFoundError unless client

        if operator == "add"
          client.scopes = client.scopes.concat(updated_scopes)
        else
          scopes_to_remove = client.scopes & updated_scopes

          scopes_to_remove.each do |scope|
            client.scopes.delete(scope)
          end
        end
        @container.client_gateway.update client
      end
    end
  end
end
