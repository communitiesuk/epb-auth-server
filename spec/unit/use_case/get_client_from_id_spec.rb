describe UseCase::GetClientFromId do
  context "a client that exists" do
    describe "fetching the client" do
      let(:client_id) { "72d1d680-92ee-463a-98a8-f3e3973df038" }
      let(:client_secret) { "test-client-secret" }
      let(:client) do
        UseCase::GetClientFromId.new(Container.new)
                                .execute client_id
      end

      it "client has the right name" do
        expect(client.name).to eq "test-client"
      end
    end

    describe "an invalid client id and secret" do
      let(:client_id) { "72d1d680-0000-463a-98a8-f3e3973df038" }
      let(:client_secret) { "test-client-secret" }

      it "returns a nil client" do
        client = UseCase::GetClientFromIdAndSecret.new(Container.new)
                                                  .execute(
                                                    client_id,
                                                    client_secret,
                                                  )

        expect(client).to be_nil
      end
    end
  end
end
