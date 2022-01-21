describe UseCase::Client::CreateNewClient do
  context "a valid client" do
    describe "a valid request" do
      let(:client_hash) do
        {
          name: "test-client",
          scopes: %w[scope:test scope:create],
          supplemental: { test: true },
        }
      end

      let(:client) do
        described_class.new(Container.new).execute client_hash
      end

      it "has the right name" do
        expect(client.name).to eq client_hash[:name]
      end

      it "has the right scopes" do
        expect(client.scopes).to eq client_hash[:scopes]
      end

      it "has the right supplemental data" do
        expect(client.supplemental).to eq client_hash[:supplemental]
      end
    end
  end
end
