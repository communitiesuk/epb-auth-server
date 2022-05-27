module Controller
  class ApiUserController < BaseController
    post prefix_route("/api/user") do
      authorize scopes: %w[user:create]

      user = container.create_new_user_use_case.execute json_body.slice :email,
                                                                        :name,
                                                                        :password

      json_response 201,
                    data: { user: user.to_hash },
                    meta: {}
    rescue StandardError => e
      case e
      when Boundary::Error
        raise
      else
        server_error e
      end
    end
  end
end
