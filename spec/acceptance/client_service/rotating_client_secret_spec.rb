describe "Acceptance: Rotating a client secret" do
  context "with correct credentials" do
    describe "a client that does not exist" do
      let(:token) do
        Auth::Token.new iss: ENV["JWT_ISSUER"],
                        sub: "does-not-exist",
                        iat: Time.now.to_i,
                        exp: Time.now.to_i + (60 * 60),
                        scopes: []
      end
      let(:response) do
        header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
        post "/api/client/does-not-exist/rotate-secret"
      end

      it "tells the client they do not exist" do
        expect(response.status).to eq 404
      end
    end
  end

  context "without credentials" do
    let(:response) do
      post "/api/client/does-not-exist/rotate-secret"
    end

    it "tells the client they are not authenticated" do
      expect(response.status).to eq 401
    end
  end

  context "with another client's credentials" do
    let(:response) do
      header "Authorization", "Bearer " + @client_test_token.encode(ENV["JWT_SECRET"])
      post "/api/client/another-client-id/rotate-secret"
    end

    it "tells the client they do not have permission to rotate the secret" do
      expect(response.status).to eq 403
    end
  end
end
