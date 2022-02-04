describe UseCase::Client::RotateAClientSecret do
  context "a client that exists" do
    describe "a valid client id and secret" do
      let(:client) { create_client }

      it "returns a client with a new secret" do
        rotated = described_class.new(Container.new)
                                 .execute client.id

        expect(rotated.secret).not_to eq client.secret
      end

      it "sets superseded_at of the old client secret to 1 day from now" do
        Timecop.freeze(2022, 0o1, 24, 8, 0, 0) do
          Gateway::ClientGateway::Model::ClientSecret.where(client_id: client.id).update_all(last_used_at: Time.now)

          described_class.new(Container.new).execute(client.id)

          old_secret = Gateway::ClientGateway::Model::ClientSecret.find_by(client_id: client.id)
          expect(old_secret.superseded_at).to eq(Time.new(2022, 0o1, 25, 8, 0, 0))
        end
      end
    end
  end
end
