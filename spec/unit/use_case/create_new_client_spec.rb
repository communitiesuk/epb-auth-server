describe UseCase::CreateNewClient do
  context "a valid client" do
    describe "a valid request" do
      let(:client_name) { "test-client" }
      let(:client_scopes) { %w[scope:test scope:create] }
      let(:client_supplemental) { { "test" => true } }

      let(:client) do
        UseCase::CreateNewClient.new(Container.new)
                                .execute(
                                  client_name,
                                  client_scopes,
                                  client_supplemental,
                                )
      end

      it "has the right name" do
        expect(client.name).to eq client_name
      end

      it "has the right scopes" do
        expect(client.scopes).to eq client_scopes
      end

      it "has the right supplemental data" do
        expect(client.supplemental).to eq client_supplemental
      end
    end
  end
end
