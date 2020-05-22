describe UseCase::AuthenticateAClient do
  context "a client that exists" do
    describe "a valid client id and secret" do
      let(:client_id) { @client_test.id }
      let(:client_secret) { @client_test.secret }

      it "finds the client" do
        client = described_class.new(Container.new)
                                .execute client_id,
                                         client_secret

        expect(client.id).to eq client_id
      end
    end

    describe "an invalid client id and secret" do
      let(:client_id) { "72d1d680-0000-463a-98a8-f3e3973df038" }
      let(:client_secret) { @client_test.secret }

      it "returns a nil client" do
        client = described_class.new(Container.new)
                                .execute client_id,
                                         client_secret

        expect(client).to be_nil
      end
    end
  end
end
