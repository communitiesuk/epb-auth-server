module UseCase
  module User
    class CreateNewUser < UseCase::BaseUseCase
      def execute(email: nil, name: nil, password: nil)
        user = {
          email: email,
          name: name,
          password: password,
        }

        @container.validation_helper.validate(
          {
            email: %w[email],
            name: %w[not_empty],
            password: %w[not_empty],
          },
          user,
        )

        @container.user_gateway.create user
      end
    end
  end
end
