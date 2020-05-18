# frozen_string_literal: true

describe Controller::ApiClientController do
  context "creating a new client as an authenticated client without scopes" do
    token =
      Auth::Token.new(
        iss: ENV["JWT_ISSUER"],
        sub: "72d1d680-92ee-463a-98a8-f3e3973df038",
        iat: Time.now.to_i,
      )

    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      post "/api/client",
           { name: "test-create-client" }.to_json,
           CONTENT_TYPE: "application/json"
    end

    let(:body) { JSON.parse response.body }

    it "returns a created status" do
      expect(response.status).to eq 201
    end

    it "returns the name correctly" do
      expect(body["data"]["client"]["name"]).to eq "test-create-client"
    end

    it "returns a valid client id" do
      expect(body["data"]["client"]["id"]).to be_a_valid_uuid
    end

    it "returns a valid client secret" do
      expect(body["data"]["client"]["secret"].length).to eq 64
    end

    it "returns an empty list of scopes" do
      expect(body["data"]["client"]["scopes"].empty?).to be_truthy
    end

    it "returns no supplemental data" do
      expect(body["data"]["client"]["supplemental"].empty?).to be_truthy
    end
  end

  context "creating a new client as an authenticated client with scopes and supplemental data" do
    token =
      Auth::Token.new(
        iss: ENV["JWT_ISSUER"],
        sub: "72d1d680-92ee-463a-98a8-f3e3973df038",
        iat: Time.now.to_i,
      )

    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      post "/api/client",
           {
             name: "test-create-client",
             scopes: %w[scope:one scope:two],
             supplemental: { test: true },
           }.to_json,
           CONTENT_TYPE: "application/json"
    end

    let(:body) { JSON.parse response.body }

    it "returns a created status" do
      expect(response.status).to eq 201
    end

    it "returns the name correctly" do
      expect(body["data"]["client"]["name"]).to eq "test-create-client"
    end

    it "returns a valid client id" do
      expect(body["data"]["client"]["id"]).to be_a_valid_uuid
    end

    it "returns a valid client secret" do
      expect(body["data"]["client"]["secret"].length).to eq 64
    end

    it "returns a list of scopes" do
      expect(body["data"]["client"]["scopes"]).to contain_exactly "scope:one", "scope:two"
    end

    it "returns some supplemental data" do
      expect(body["data"]["client"]["supplemental"]).to eq "test" => true
    end
  end

  context "creating a new client as an unauthenticated client" do
    let(:response) { post "/api/client", name: "test-create-client" }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.body).to include "Auth::Errors::TokenMissing"
    end
  end
end
