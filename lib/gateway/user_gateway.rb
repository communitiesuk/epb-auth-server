require "active_support"
require "active_support/core_ext"
require "sinatra/activerecord"
require "acts_as_paranoid"

module Gateway
  class UserGateway
    module Model
      class User < ActiveRecord::Base
        validates_presence_of :email, :name, :password
        acts_as_paranoid
      end
    end

    def create(email:, name:, password:)
      model = Model::User.create! email: email,
                                  name: name,
                                  password: hash_password(password)

      Domain::User.new id: model.id,
                       name: model.name,
                       email: model.email
    end

    def fetch(attributes)
      model = Model::User.find_by(attributes)

      unless model.nil?
        Domain::User.new id: model.id,
                         name: model.name,
                         email: model.email
      end
    end

    def update(user)
      ActiveRecord::Base.transaction do
        model = Model::User.find_by(user.to_hash.slice(:id))

        model.update! user.to_hash.slice(:email, :name)

        fetch user.to_hash.slice(:id)
      end
    end

    def delete(user)
      ActiveRecord::Base.transaction do
        model = Model::User.find_by(user.to_hash.slice(:id))

        model.destroy
      end
    end

  private

    def hash_password(password)
      sql = "SELECT crypt($1, gen_salt('bf')) AS hashed_password"
      binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "password",
          password,
          ActiveRecord::Type::String.new,
        ),
      ]

      results = ActiveRecord::Base.connection.exec_query sql, "SQL", binds

      results[0] && results[0]["hashed_password"]
    end
  end
end
