class Container
  attr_reader :client_gateway

  def initialize
    @client_gateway = Gateway::ClientGateway.new
  end
end
