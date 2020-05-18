module UseCase
  class CreateNewClient
    def initialize(container)
      @container = container
    end

    def execute(name, scopes, supplemental)
      @container.client_gateway.create name: name,
                                       scopes: scopes,
                                       supplemental: supplemental
    end
  end
end
