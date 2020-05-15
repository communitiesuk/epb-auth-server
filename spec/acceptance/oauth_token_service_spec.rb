# frozen_string_literal: true

require "base64"

describe OAuthTokenService do
  context "requesting a new token with valid client credentials in the header" do
    client_id = "72d1d680-92ee-463a-98a8-f3e3973df038"
    client_secret = "test-client-secret"

    auth_header = Base64.encode64([client_id, client_secret].join(":"))

    let(:response) do
      header "Authorization", "Basic " + auth_header
      post "/oauth/token"
    end

    let(:body) { JSON.parse response.body }

    it "gives a status of 200" do
      expect(response.status).to eq 200
    end

    it "gives a response with a valid jwt based access_token" do
      expect(body["access_token"]).to be_a_valid_jwt_token
    end

    it "gives a response with a token that expires at least an hour in the future" do
      expect(body["expires_in"]).to be >= 3_600
    end

    it "gives a response with a token of type Bearer" do
      expect(body["token_type"]).to eq "bearer"
    end

    it "gives a response with scopes" do
      processor = Auth::TokenProcessor.new ENV["JWT_SECRET"], ENV["JWT_ISSUER"]
      token = processor.process body["access_token"]

      expect(token.scopes?(%w[scope:one scope:two])).to be_truthy
    end

    it "gives a response with supplemental data" do
      processor = Auth::TokenProcessor.new ENV["JWT_SECRET"], ENV["JWT_ISSUER"]
      token = processor.process body["access_token"]

      expect(token.supplemental("test")).to contain_exactly true
    end
  end

  context "requesting a new token with valid client credentials in the request body" do
    client_id = "72d1d680-92ee-463a-98a8-f3e3973df038"
    client_secret = "test-client-secret"

    let(:response) do
      post "/oauth/token", client_id: client_id, client_secret: client_secret
    end

    let(:body) { JSON.parse response.body }

    it "gives a status of 200" do
      expect(response.status).to eq 200
    end

    it "gives a response with a valid jwt based access_token" do
      expect(body["access_token"]).to be_a_valid_jwt_token
    end

    it "gives a response with a token that expires at least an hour in the future" do
      expect(body["expires_in"]).to be >= 3_600
    end

    it "gives a response with a token of type Bearer" do
      expect(body["token_type"]).to eq "bearer"
    end
  end

  context "requesting a new token without valid client credentials in the header" do
    client_id = "invalid-id"
    client_secret = "invalid-secret"

    auth_header = Base64.encode64([client_id, client_secret].join(":"))

    let(:response) do
      header "Authorization", "Basic " + auth_header
      post "/oauth/token"
    end

    it "gives a status of 401" do
      expect(response.status).to eq 401
    end
  end

  context "requesting a new token without valid client credentials in the request body" do
    client_id = "invalid-id"
    client_secret = "invalid-secret"

    let(:response) do
      post "/oauth/token", client_id: client_id, client_secret: client_secret
    end

    it "gives a status of 401" do
      expect(response.status).to eq 401
    end
  end

  context "requesting a new token with valid client credentials with a : in the secret" do
    client_id = "54d1d680-92ee-463a-98a8-f3e3973df038"
    client_secret = "test-client-secret-with-:-in-it"

    auth_header = Base64.encode64([client_id, client_secret].join(":"))

    let(:response) do
      header "Authorization", "Basic " + auth_header
      post "/oauth/token"
    end

    let(:body) { JSON.parse response.body }

    it "gives a status of 200" do
      expect(response.status).to eq 200
    end
  end
end
