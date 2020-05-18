module UseCase
  class GetClientFromId
    def initialize(container)
      @container = container
    end

    def execute(id)
      @container.client_gateway.fetch id: id
    end
  end
end
