class Container
  attr_reader :client_gateway,
              :create_new_client_use_case,
              :get_client_from_id_use_case,
              :authenticate_a_client,
              :update_client_use_case,
              :delete_client_use_case

  def initialize
    @client_gateway =
      Gateway::ClientGateway.new
    @create_new_client_use_case =
      UseCase::CreateNewClient.new self
    @get_client_from_id_use_case =
      UseCase::GetClientFromId.new self
    @authenticate_a_client =
      UseCase::AuthenticateAClient.new self
    @update_client_use_case =
      UseCase::UpdateClient.new self
    @delete_client_use_case =
      UseCase::DeleteClient.new self
  end
end
