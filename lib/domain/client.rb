module Domain
  class Client
    attr_accessor :id, :name, :secret, :scopes, :supplemental

    def initialize(id:, name:, secret: nil, scopes: [], supplemental: {})
      self.id = id
      self.name = name
      self.secret = secret
      self.scopes = scopes
      self.supplemental = supplemental
    end

    def to_hash
      { id: id, name: name, scopes: scopes, supplemental: supplemental }
    end
  end
end
