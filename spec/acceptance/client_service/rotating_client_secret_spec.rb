describe "Acceptance: Rotating a client secret" do
  context "without credentials" do
    let(:response) do
      post "/api/client/does-not-exist/rotate-secret"
    end

    it "tells the client they are not authenticated" do
      expect(response.status).to eq 401
    end
  end
end
