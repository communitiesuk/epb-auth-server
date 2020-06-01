class Container
  attr_reader :validation_helper,
              :client_gateway,
              :create_new_client_use_case,
              :get_client_from_id_use_case,
              :authenticate_a_client,
              :update_client_use_case,
              :delete_client_use_case,
              :rotate_a_client_secret_use_case,
              :user_gateway,
              :create_new_user_use_case

  def initialize
    @validation_helper = Helper::ValidationHelper.new

    @client_gateway =
      Gateway::ClientGateway.new
    @create_new_client_use_case =
      UseCase::Client::CreateNewClient.new self
    @get_client_from_id_use_case =
      UseCase::Client::GetClientFromId.new self
    @authenticate_a_client =
      UseCase::Client::AuthenticateAClient.new self
    @update_client_use_case =
      UseCase::Client::UpdateClient.new self
    @delete_client_use_case =
      UseCase::Client::DeleteClient.new self
    @rotate_a_client_secret_use_case =
      UseCase::Client::RotateAClientSecret.new self

    @user_gateway = Gateway::UserGateway.new
    @create_new_user_use_case = UseCase::User::CreateNewUser.new self
  end
end
