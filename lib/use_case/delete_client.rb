module UseCase
  class DeleteClient
    class ClientNotFoundError < StandardError; end

    def initialize(container)
      @container = container
    end

    def execute(id)
      client = @container.client_gateway.fetch id: id

      raise ClientNotFoundError unless client

      @container.client_gateway.delete client
    end
  end
end
