describe UseCase::Client::GetClientFromId do
  context "with a client that exists" do
    let(:client) { create_client }

    describe "fetching the client" do
      let(:fetched_client) { described_class.new(Container.new).execute client.id }

      it "client has the right name" do
        expect(fetched_client.name).to eq client.name
      end
    end
  end
end
