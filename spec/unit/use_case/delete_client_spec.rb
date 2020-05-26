describe UseCase::Client::DeleteClient do
  context "a valid client" do
    describe "a valid request" do
      let(:client) { create_client }

      it "fetching the client returns a nil" do
        container = Container.new

        described_class.new(container).execute client.id

        deleted_client = container.get_client_from_id_use_case.execute client.id
        expect(deleted_client).to be_nil
      end
    end
  end
end
