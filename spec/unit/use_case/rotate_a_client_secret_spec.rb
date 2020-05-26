describe UseCase::RotateAClientSecret do
  context "a client that exists" do
    describe "a valid client id and secret" do
      let(:client) { create_client }

      it "returns a client with a new secret" do
        rotated = described_class.new(Container.new)
                                 .execute client.id

        expect(rotated.secret).not_to eq client.secret
      end
    end
  end
end
