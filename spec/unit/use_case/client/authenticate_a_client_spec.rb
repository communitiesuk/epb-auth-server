describe UseCase::Client::AuthenticateAClient do
  context "a client that exists" do
    describe "a valid secret" do
      let(:client) { create_client }

      it "finds the client" do
        response = described_class.new(Container.new)
                                  .execute client.id,
                                           client.secret

        expect(response.id).to eq client.id
      end

      it "records when a client secret was last used" do
        response = described_class.new(Container.new)
                                  .execute client.id,
                                           client.secret
        client_secret = find_client_secret(client.id, client.secret).first

        expect(client_secret["last_used_at"]).to be_within(5.seconds).of(Time.now)
      end
    end

    describe "an invalid secret" do
      let(:client) { create_client }

      it "returns a nil client" do
        response = described_class.new(Container.new)
                                  .execute client.id,
                                           "invalid"

        expect(response).to be_nil
      end
    end
  end
end
