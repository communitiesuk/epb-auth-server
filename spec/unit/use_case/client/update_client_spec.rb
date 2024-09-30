describe UseCase::Client::UpdateClient do
  context "when using a valid client" do
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
        expect(client.supplemental).to eq({ test: false })
      end
    end
  end

  describe "a valid patch request" do
    let(:test_client) { create_client(scopes: %w[scope:one scope:two]) }
    let(:client_id) { test_client.id }
    let(:current_client) { test_client }
    let(:add_scopes) { %w[scope:three scope:four] }
    let(:duplicate_scopes) { %w[scope:one] }
    let(:remove_scopes) { %w[scope:two] }
    let(:remove_more_scopes) { %w[scope:two scope:five scope:seven] }

    it "adds the right scopes" do
      client = described_class.new(Container.new).execute_patch client_id, "add", add_scopes
      expect(client.scopes).to eq %w[scope:one scope:two scope:three scope:four]
    end

    it "does not duplicate scopes" do
      client = described_class.new(Container.new).execute_patch client_id, "add", duplicate_scopes
      expect(client.scopes).to eq %w[scope:one scope:two]
    end

    it "removes the right scopes" do
      client = described_class.new(Container.new).execute_patch client_id, "remove", remove_scopes
      expect(client.scopes).to eq %w[scope:one]
    end

    it "removes the right scopes when given more scopes" do
      client = described_class.new(Container.new).execute_patch client_id, "remove", remove_more_scopes
      expect(client.scopes).to eq %w[scope:one]
    end
  end
end
