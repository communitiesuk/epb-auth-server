# frozen_string_literal: true

describe "Acceptance: Updating a client" do
  context "updating a client as an authenticated client" do
    let(:response) do
      header "Authorization", "Bearer " + @client_test_token.encode(ENV["JWT_SECRET"])
      put "/api/client/#{@client_test.id}",
          {
            name: "updated-client-name",
            scopes: %w[scope:three scope:four],
            supplemental: { test: false },
          }.to_json,
          {
            "CONTENT_TYPE" => "application/json",
          }
    end

    let(:body) { JSON.parse response.body }

    it "returns an updated status" do
      expect(response.status).to eq 200
    end

    it "returns the name correctly" do
      expect(body["data"]["client"]["name"]).to eq "updated-client-name"
    end

    it "returns a valid client id" do
      expect(body["data"]["client"]["id"]).to be_a_valid_uuid
    end

    it "returns no client secret" do
      expect(body["data"]["client"]["secret"]).to be_nil
    end

    it "returns an updated list of scopes" do
      expect(body["data"]["client"]["scopes"]).to eq %w[scope:three scope:four]
    end

    it "returns updated supplemental data" do
      expect(body["data"]["client"]["supplemental"]).to eq({ "test" => false })
    end
  end

  context "updating a client as an unauthenticated client" do
    let(:response) { put "/api/client/#{@client_test.id}" }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.body).to include "Auth::Errors::TokenMissing"
    end
  end

  context "updating a client as an unauthorised client" do
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: @client_test.id,
                      iat: Time.now.to_i,
                      exp: Time.now.to_i + (60 * 60),
                      scopes: []
    end
    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      put "/api/client/#{@client_test.id}",
          {
            name: "updated-client-name",
            scopes: %w[scope:three scope:four],
            supplemental: { test: false },
          }.to_json,
          {
            "CONTENT_TYPE" => "application/json",
          }
    end

    let(:body) { JSON.parse response.body }

    it "fails with an appropriate code" do
      expect(response.status).to eq 403
    end

    it "fails with an appropriate error message" do
      expect(response.body).to include "InsufficientPrivileges"
    end
  end
end
