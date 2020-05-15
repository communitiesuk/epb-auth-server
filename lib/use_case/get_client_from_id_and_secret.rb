module UseCase
  class GetClientFromIdAndSecret
    def initialize(container)
      @container = container
    end

    def execute(id, secret)
      @container.client_gateway.fetch id: id, secret: secret
    end
  end
end
