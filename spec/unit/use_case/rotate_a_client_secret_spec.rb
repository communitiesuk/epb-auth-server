describe UseCase::RotateAClientSecret do
  context "a client that exists" do
    describe "a valid client id and secret" do
      let(:client_id) { @client_test.id }
      let(:client_secret) { @client_test.secret }

      it "returns a client with a new secret" do
        client = described_class.new(Container.new)
                                .execute client_id

        expect(client.secret).not_to eq client_secret
      end
    end

    describe "an invalid client id and secret" do
      let(:client_id) { "72d1d680-0000-463a-98a8-f3e3973df038" }

      it "raises a client not found error" do


        expect {
          described_class.new(Container.new).execute client_id
        }.to raise_error described_class::ClientNotFoundError
      end
    end
  end
end
