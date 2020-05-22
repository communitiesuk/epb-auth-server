describe UseCase::GetClientFromId do
  context "a client that exists" do
    describe "fetching the client" do
      let(:client_id) { @client_test.id }
      let(:client_secret) { @client_test.secret }
      let(:client) do
        UseCase::GetClientFromId.new(Container.new)
                                .execute client_id
      end

      it "client has the right name" do
        expect(client.name).to eq "test-client"
      end
    end

    describe "an invalid client id and secret" do
      let(:client_id) { "does-not-exist" }
      let(:client_secret) { "does-not-exist-secret" }

      it "returns a nil client" do
        client = UseCase::AuthenticateAClient.new(Container.new)
                                             .execute client_id,
                                                      client_secret

        expect(client).to be_nil
      end
    end
  end
end
