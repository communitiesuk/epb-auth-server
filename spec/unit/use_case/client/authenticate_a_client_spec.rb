describe UseCase::Client::AuthenticateAClient do
  context "when using a client that exists" do
    describe "a valid secret" do
      let(:client) { create_client }

      it "finds the client" do
        response = described_class.new(Container.new)
                                  .execute client.id,
                                           client.secret

        expect(response.id).to eq client.id
      end

      it "records when a client secret was last used" do
        Timecop.freeze(2022, 0o1, 24, 8, 0, 0) do
          described_class.new(Container.new)
                                    .execute client.id,
                                             client.secret
          client_secret = find_client_secret(client.id, client.secret).first

          expect(client_secret["last_used_at"]).to eq(Time.new(2022, 0o1, 24, 8, 0, 0))
        end
      end

      it "authenticates when secret was superseded but is still valid" do
        Gateway::ClientGateway::Model::ClientSecret.where(client_id: client.id)
          .update_all(superseded_at: Time.now + 1.day)

        response = described_class.new(Container.new)
                                  .execute client.id,
                                           client.secret

        expect(response.id).to eq client.id
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

      it "does not authenticate when the secret was superseded" do
        Gateway::ClientGateway::Model::ClientSecret.where(client_id: client.id)
          .update_all(superseded_at: Time.now - 1.day)

        response = described_class.new(Container.new)
                                  .execute client.id,
                                           client.secret

        expect(response).to be_nil
      end
    end
  end
end
