describe Gateway::UserGateway do
  let(:gateway) { described_class.new }

  describe "creating a new user" do
    let(:name) { "test-user" }
    let(:email) { "test-user@example.com" }
    let(:password) { "test-password" }
    let(:user) { gateway.create email: email, name: name, password: password }

    it "has a valid id" do
      expect(user.id).not_to be_nil
    end

    it "has the correct name" do
      expect(user.name).to eq name
    end

    it "has the correct email" do
      expect(user.email).to eq email
    end

    it "has a hashed password" do
      expect(user.password).not_to eq password
    end
  end

  describe "fetching an existing user" do
    let(:created_user) { create_user }
    let(:user) { gateway.fetch id: created_user.id }

    it "has the correct email" do
      expect(user.email).to eq created_user.email
    end

    it "has the correct name" do
      expect(user.name).to eq created_user.name
    end

    it "does not return a password" do
      expect(user.password).to be_nil
    end
  end

  describe "updating an existing user" do
    let(:created_user) { create_user }
    let(:user) { gateway.fetch id: created_user.id }

    describe "updating the name" do
      let(:name) { "new-user-name" }

      it "has the new name" do
        user_with_new_name = user.dup
        user_with_new_name.name = name

        gateway.update(user_with_new_name)

        new_user = gateway.fetch(id: user.id)

        expect(new_user.name).to eq name
      end
    end

    describe "updating the email" do
      let(:email) { "test@example.com" }

      it "has the new email" do
        user_with_new_email = user.dup
        user_with_new_email.email = email

        gateway.update(user_with_new_email)

        new_user = gateway.fetch(id: user.id)

        expect(new_user.email).to eq email
      end
    end
  end

  describe "deleting an existing user" do
    let(:user) { create_user }

    describe "deleting the user" do
      it "is not available in the gateway" do
        gateway.delete(user)

        deleted_user = gateway.fetch(id: user.id)

        expect(deleted_user).to be_nil
      end
    end
  end
end
