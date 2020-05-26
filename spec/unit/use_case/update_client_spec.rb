describe UseCase::UpdateClient do
  context "a valid client" do
    describe "a valid request" do
      let(:test_client) { create_client }
      let(:client_id) { test_client.id }
      let(:client_name) { "test-client-updated" }
      let(:client_scopes) { %w[scope:three scope:four] }
      let(:client_supplemental) { { test: false } }

      let(:client) do
        described_class.new(Container.new).execute client_id,
                                                   client_name,
                                                   client_scopes,
                                                   client_supplemental
      end

      it "has the right name" do
        expect(client.name).to eq client_name
      end

      it "has the right scopes" do
        expect(client.scopes).to eq client_scopes
      end

      it "has the right supplemental data" do
        expect(client.supplemental).to eq({ "test" => false })
      end
    end
  end
end
