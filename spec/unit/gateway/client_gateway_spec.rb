# frozen_string_literal: true

require "rspec"

describe Gateway::ClientGateway do
  let(:gateway) { described_class.new }

  context "when creating a new client object" do
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

  context "when getting an existing client object" do
    let(:client) { gateway.fetch id: "72d1d680-92ee-463a-98a8-f3e3973df038" }

    it "has the correct id" do
      expect(client.id).to eq "72d1d680-92ee-463a-98a8-f3e3973df038"
    end

    it "has the correct name" do
      expect(client.name).to eq "test-client"
    end

    it "does not return a secret" do
      expect(client.secret).to be_nil
    end
  end

  context "when updating an existing client" do
    let(:client_id) { "72d1d680-92ee-463a-98a8-f3e3973df038" }
    let(:client) { gateway.fetch id: client_id }

    describe "updating the name" do
      let(:name) { "new-client-name" }

      it "has the new name" do
        client_with_new_name = client.dup
        client_with_new_name.name = name

        gateway.update(client_with_new_name)

        new_client = gateway.fetch(id: client_id)

        expect(new_client.name).to eq name
      end
    end

    describe "updating the scopes" do
      let(:scopes) { %w[scope:one scope:three] }

      it "has the new scopes" do
        client_with_new_scopes = client.dup
        client_with_new_scopes.scopes = scopes

        gateway.update(client_with_new_scopes)

        new_client = gateway.fetch(id: client_id)

        expect(new_client.scopes).to eq scopes
      end
    end

    describe "updating the supplemental date" do
      let(:supplemental) { { "test" => false } }

      it "has the new supplemental data" do
        client_with_new_supplemental_data = client.dup
        client_with_new_supplemental_data.supplemental = supplemental

        gateway.update(client_with_new_supplemental_data)

        new_client = gateway.fetch(id: client_id)

        expect(new_client.supplemental).to eq supplemental
      end
    end
  end
end
