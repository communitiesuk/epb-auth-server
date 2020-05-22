describe "fetching details of a client" do
  describe "fetching an existing client" do
    let(:client) do
      {
        id: @client_test.id,
        name: "test-client",
        secret: @client_test.secret,
        supplemental: { test: [true] },
        scopes: %w[scope:one scope:two],
      }
    end
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: @client_test.id,
                      iat: Time.now.to_i,
                      scopes: %w[client:fetch]
    end
    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      get "/api/client/#{client[:id]}"
    end
    let(:body) { JSON.parse response.body }

    it "returns an ok status code" do
      expect(response.status).to eq 200
    end

    it "the fetched client has the right name" do
      expect(body["data"]["client"]["name"]).to eq "test-client"
    end

    it "the fetched client has the right scopes" do
      expect(body["data"]["client"]["scopes"]).to eq %w[scope:one scope:two]
    end

    it "the fetched client has the right supplemental data" do
      expect(body["data"]["client"]["supplemental"]).to eq({ "test" => [true] })
    end

    it "the fetched client has no secret" do
      expect(body["data"]["client"]["secret"]).to be_nil
    end
  end

  describe "fetching a client that does not exist" do
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: @client_test.id,
                      iat: Time.now.to_i,
                      scopes: %w[client:fetch]
    end
    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      get "/api/client/NONEXISTANT_CLIENT"
    end
    let(:body) { JSON.parse response.body }

    it "returns a not found status code" do
      expect(response.status).to eq 404
    end

    it "returns a valid error" do
      expect(body["error"]).to eq "Could not find client NONEXISTANT_CLIENT"
    end
  end

  describe "fetching a client as an unauthenticated user" do
    let(:response) do
      get "/api/client/#{@client_test.id}"
    end
    let(:body) { JSON.parse response.body }

    it "returns a not found status code" do
      expect(response.status).to eq 401
    end
  end

  describe "fetching a client as an unauthorised user" do
    let(:token) do
      Auth::Token.new iss: ENV["JWT_ISSUER"],
                      sub: @client_test.id,
                      iat: Time.now.to_i
    end
    let(:response) do
      header "Authorization", "Bearer " + token.encode(ENV["JWT_SECRET"])
      get "/api/client/NONEXISTANT_CLIENT"
    end
    let(:body) { JSON.parse response.body }

    it "returns a not found status code" do
      expect(response.status).to eq 403
    end
  end
end
