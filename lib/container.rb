class Container
  attr_reader :client_gateway,
              :create_new_client_use_case,
              :get_client_from_id_and_secret_use_case

  def initialize
    @client_gateway =
      Gateway::ClientGateway.new
    @create_new_client_use_case =
      UseCase::CreateNewClient.new self
    @get_client_from_id_and_secret_use_case =
      UseCase::GetClientFromIdAndSecret.new self
  end
end
