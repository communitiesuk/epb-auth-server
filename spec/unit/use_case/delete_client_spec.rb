describe UseCase::DeleteClient do
  context "a valid client" do
    describe "a valid request" do
      let(:client_id) { "93d1d680-92ee-463a-98a8-f3e3973df038" }

      it "fetching the client returns a nil" do
        container = Container.new

        described_class.new(container).execute client_id

        deleted_client = container.get_client_from_id_use_case.execute client_id
        expect(deleted_client).to be_nil
      end
    end
  end
end
