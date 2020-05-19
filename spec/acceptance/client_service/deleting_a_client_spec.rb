# frozen_string_literal: true

describe "deleting a client" do
  context "deleting a client as an authenticated client" do
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: "72d1d680-92ee-463a-98a8-f3e3973df038",
                      iat: Time.now.to_i,
                      scopes: %w[client:delete client:fetch]
    end
    let(:delete_response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      delete "/api/client/93d1d680-92ee-463a-98a8-f3e3973df038"
    end

    it "the client is deleted" do
      expect(delete_response.status).to eq 200
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      fetch_response = get "/api/client/93d1d680-92ee-463a-98a8-f3e3973df038"
      expect(fetch_response.status).to eq 404
    end
  end

  context "deleting a client as an unauthenticated client" do
    let(:response) { delete "/api/client/93d1d680-92ee-463a-98a8-f3e3973df038" }

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
                      sub: "72d1d680-92ee-463a-98a8-f3e3973df038",
                      iat: Time.now.to_i
    end

    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      delete "/api/client/93d1d680-92ee-463a-98a8-f3e3973df038"
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
