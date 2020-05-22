# frozen_string_literal: true

describe "Acceptance: Deleting a client" do
  context "deleting a client as an authenticated client" do
    let(:delete_response) do
      header "Authorization", "Bearer " + @client_test_token.encode(ENV["JWT_SECRET"])
      delete "/api/client/#{@client_test.id}"
    end

    it "the client is deleted" do
      expect(delete_response.status).to eq 200
      header "Authorization", "Bearer " + @client_test_token.encode(ENV["JWT_SECRET"])
      fetch_response = get "/api/client/#{@client_test.id}"

      expect(fetch_response.status).to eq 404
    end
  end

  context "deleting a client as an unauthenticated client" do
    let(:response) { delete "/api/client/#{@client_test.id}" }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.body).to include "Auth::Errors::TokenMissing"
    end
  end

  context "deleting a client as an unauthorised client" do
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: @client_test.id,
                      iat: Time.now.to_i,
                      exp: Time.now.to_i + (60 * 60),
                      scopes: []
    end
    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      delete "/api/client/#{@client_test.id}"
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
