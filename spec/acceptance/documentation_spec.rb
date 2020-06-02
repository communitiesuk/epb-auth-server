describe "Acceptance: Documentation route" do
  context "responses from /" do
    let(:response) { get "/" }

    it "returns status 200" do
      expect(response.status).to eq 200
    end
  end
end
