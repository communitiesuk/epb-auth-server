module Domain
  class User
    attr_accessor :id, :name, :email, :password

    def initialize(id:, email:, name:, password: nil)
      self.id = id
      self.email = email
      self.name = name
      self.password = password
    end

    def to_hash
      { id:, email:, name: }
    end
  end
end
