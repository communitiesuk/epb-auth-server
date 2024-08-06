describe UseCase::Client::DeleteClient do
  context "with an existing client" do
    let(:client) { create_client }

    describe "deleting the client" do
      let(:delete_client) { described_class.new(container).execute client.id }

      it "returns true" do
        expect(delete_client).to be true
      end

      describe "deleting the client a second time" do
        it "raises a NotFound error" do
          described_class.new(container).execute client.id

          expect {
            described_class.new(container).execute client.id
          }.to raise_error Boundary::NotFoundError
        end
      end
    end
  end

  context "with a client that does not exist" do
    describe "deleting the client" do
      it "raises a NotFound error" do
        expect {
          described_class.new(container).execute Faker::Internet.uuid
        }.to raise_error Boundary::NotFoundError
      end
    end
  end
end
