# frozen_string_literal: true

describe Service do
  context "responses from /" do
    let(:response) { get "/" }

    it "returns status 200" do
      expect(response.status).to eq 200
    end
  end

  context "responses from /healthcheck" do
    let(:response) { get "/healthcheck" }

    it "returns status 200" do
      expect(response.status).to eq 200
    end

    it "returns an ok message" do
      expect(JSON.parse(response.body)["message"]).to eq "ok"
    end
  end
end
