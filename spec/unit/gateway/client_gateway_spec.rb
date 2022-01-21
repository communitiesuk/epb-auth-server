require "rspec"

describe Gateway::ClientGateway do
  let(:gateway) { described_class.new }

  describe "creating a new client" do
    let(:client_name) { "test-client" }
    let(:client) do
      gateway.create name: client_name, scopes: %w[scope:one scope:two]
    end

    it "has the correct id" do
      expect(client.id).not_to be_nil
    end

    it "has the correct name" do
      expect(client.name).to eq client_name
    end

    it "has a valid secret" do
      expect(client.secret.length).to eq 64
    end

    it "has the correct scopes" do
      expect(client.scopes).to eq %w[scope:one scope:two]
    end
  end

  describe "fetching an existing client" do
    let(:created_client) { create_client }
    let(:client) { gateway.fetch id: created_client.id }

    it "has the correct id" do
      expect(client.id).to eq created_client.id
    end

    it "has the correct name" do
      expect(client.name).to eq created_client.name
    end

    it "does not return a secret" do
      expect(client.secret).to be_nil
    end
  end

  describe "updating an existing client" do
    let(:created_client) { create_client }
    let(:client) { gateway.fetch id: created_client.id }

    describe "updating the name" do
      let(:name) { "new-client-name" }

      it "has the new name" do
        client_with_new_name = client.dup
        client_with_new_name.name = name

        gateway.update(client_with_new_name)

        new_client = gateway.fetch(id: client.id)

        expect(new_client.name).to eq name
      end
    end

    describe "updating the scopes" do
      let(:scopes) { %w[scope:one scope:three] }

      it "has the new scopes" do
        client_with_new_scopes = client.dup
        client_with_new_scopes.scopes = scopes

        gateway.update(client_with_new_scopes)

        new_client = gateway.fetch(id: client.id)

        expect(new_client.scopes).to eq scopes
      end
    end

    describe "updating the supplemental data" do
      let(:supplemental) { { test: false } }

      it "has the new supplemental data" do
        client_with_new_supplemental = client.dup
        client_with_new_supplemental.supplemental = supplemental

        gateway.update(client_with_new_supplemental)

        new_client = gateway.fetch(id: client.id)

        expect(new_client.supplemental).to eq supplemental
      end
    end
  end

  describe "updating last used at" do
    it "updates last used at to current time" do
      client = create_client
      gateway.update_client_secret_last_used_at(client.id, client.secret)

      client_secret = find_client_secret(client.id, client.secret).first

      expect(client_secret["last_used_at"]).to be_within(5.seconds).of(Time.now)
    end
  end

  describe "deleting an existing client" do
    let(:created_client) { create_client }
    let(:client) { gateway.fetch id: created_client.id }

    describe "deleting the client" do
      it "is not available in the gateway" do
        gateway.delete(client)

        deleted_client = gateway.fetch(id: client.id)

        expect(deleted_client).to be_nil
      end
    end
  end
end
