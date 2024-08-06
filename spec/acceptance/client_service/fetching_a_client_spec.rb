describe "Acceptance: Fetching details of a client" do
  context "when authorised" do
    let(:token) { create_token scopes: %w[client:fetch] }

    describe "fetching an existing client" do
      let(:client) { create_client scopes: %w[one two], supplemental: { test: true } }
      let(:response) do
        make_request token do
          get "/api/client/#{client.id}"
        end
      end

      it "returns an ok status code" do
        expect(response.status).to eq 200
      end

      it "the fetched client has the right name" do
        expect(response.get(%i[data client name])).to eq client.name
      end

      it "the fetched client has the right scopes" do
        expect(response.get(%i[data client scopes])).to eq client.scopes
      end

      it "the fetched client has the right supplemental data" do
        expect(response.get(%i[data client supplemental])).to eq({ test: true })
      end

      it "the fetched client has no secret" do
        expect(response.get(%i[data client secret])).to be_nil
      end
    end

    describe "fetching a client that does not exist" do
      let(:response) do
        make_request token do
          get "/api/client/NONEXISTANT_CLIENT"
        end
      end

      it "returns a not found status code" do
        expect(response.status).to eq 404
      end
    end
  end

  context "when unauthenticated" do
    describe "fetching a client" do
      let(:response) { get "/api/client/test" }

      it "returns an unauthenticated status code" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "fetching a client as an unauthorised user" do
    let(:token) { create_token }
    let(:response) do
      make_request token do
        get "/api/client/test"
      end
    end

    it "returns an unauthorised status code" do
      expect(response.status).to eq 403
    end
  end
end
