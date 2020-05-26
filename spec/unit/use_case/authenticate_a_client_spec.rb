describe UseCase::AuthenticateAClient do
  context "a client that exists" do
    describe "a valid secret" do
      let(:client) { create_client }

      it "finds the client" do
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
    end
  end
end
