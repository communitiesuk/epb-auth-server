describe "Acceptance: Rotating a client secret" do
  context "with correct credentials" do
    describe "a client that exists" do
      let(:client) { create_client }
      let(:response) do
        make_request client_token(client) do
          post "/api/client/#{client.id}/rotate-secret"
        end
      end

      it "rotates the client secret" do
        expect(response.status).to eq 200
      end

      it "returns a new secret" do
        expect(response.get(%i[data client secret])).not_to eq client.secret
      end

      it "returns a secret that can be used to request a new token" do
        auth_header = Base64.encode64 [
          client.id,
          response.get(%i[data client secret]),
        ].join(":")

        header "Authorization", "Basic #{auth_header}"
        response = post "/oauth/token"

        expect(response.status).to eq 200
      end
    end

    describe "a client that does not exist" do
      let(:token) { create_token id: "does-not-exist" }
      let(:response) do
        make_request token do
          post "/api/client/does-not-exist/rotate-secret"
        end
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
      make_request create_token do
        post "/api/client/another-client-id/rotate-secret"
      end
    end

    it "tells the client they do not have permission to rotate the secret" do
      expect(response.status).to eq 403
    end
  end
end
