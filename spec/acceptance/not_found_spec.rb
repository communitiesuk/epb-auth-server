describe "Acceptance: NotFound" do
  context "responses from a get request to a non existent endpoint" do
    let(:response) { get "/wp-admin/admin-ajax.php" }

    it "returns status 404" do
      expect(response.status).to eq 404
    end

    it "returns an ok message" do
      expect(JSON.parse(response.body)["code"]).to eq "NOT_FOUND"
    end
  end

  context "responses from a post request to a non existent endpoint" do
    let(:response) { post "/wp-admin/admin-ajax.php" }

    it "returns status 404" do
      expect(response.status).to eq 404
    end

    it "returns an ok message" do
      expect(JSON.parse(response.body)["code"]).to eq "NOT_FOUND"
    end
  end
end
