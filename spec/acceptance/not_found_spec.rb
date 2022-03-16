describe "Acceptance: NotFound" do
  context "when responding to a get request to a non existent endpoint" do
    let(:response) { get "/wp-admin/admin-ajax.php" }

    it "returns status 404" do
      expect(response.status).to eq 404
    end

    it "returns an ok message" do
      expect(JSON.parse(response.body)["code"]).to eq "NOT_FOUND"
    end
  end

  context "when responding to a post request to a non existent endpoint" do
    let(:response) { post "/wp-admin/admin-ajax.php" }

    it "returns status 404" do
      expect(response.status).to eq 404
    end

    it "returns an ok message" do
      expect(JSON.parse(response.body)["code"]).to eq "NOT_FOUND"
    end
  end
end
