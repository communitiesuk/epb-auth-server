describe "Acceptance: Creating a new client" do
  context "as an authenticated client" do
    let(:token) { client_token create_client scopes: %w[client:create] }
    describe "creating a client with only a name" do
      let(:response) do
        make_request token do
          post "/api/client",
               { name: "client-with-only-name" }.to_json,
               CONTENT_TYPE: "application/json"
        end
      end

      it "returns a created status" do
        expect(response.status).to eq 201
      end

      it "returns a valid client id" do
        expect(response.get(%i[data client id])).to be_a_valid_uuid
      end

      it "returns the name correctly" do
        expect(response.get(%i[data client name])).to eq "client-with-only-name"
      end

      it "returns a valid client secret" do
        expect(response.get(%i[data client secret]).length).to eq 64
      end

      it "returns an empty list of scopes" do
        expect(response.get(%i[data client scopes]).empty?).to be_truthy
      end

      it "returns no supplemental data" do
        expect(response.get(%i[data client supplemental]).empty?).to be_truthy
      end
    end

    describe "creating a new client with scopes and supplemental data" do
      let(:token) { client_token create_client scopes: %w[client:create] }
      let(:response) do
        make_request token do
          post "/api/client",
               {
                 name: "client-with-scopes-and-supplemental-data",
                 scopes: %w[scope:one scope:two],
                 supplemental: { test: true },
               }.to_json,
               CONTENT_TYPE: "application/json"
        end
      end

      it "returns a created status" do
        expect(response.status).to eq 201
      end

      it "returns the name correctly" do
        expect(response.get(%i[data client name])).to eq "client-with-scopes-and-supplemental-data"
      end

      it "returns a valid client id" do
        expect(response.get(%i[data client id])).to be_a_valid_uuid
      end

      it "returns a valid client secret" do
        expect(response.get(%i[data client secret]).length).to eq 64
      end

      it "returns a list of scopes" do
        expect(response.get(%i[data client scopes])).to contain_exactly "scope:one", "scope:two"
      end

      it "returns some supplemental data" do
        expect(response.get(%i[data client supplemental])).to eq test: true
      end
    end
  end

  context "as an unauthenticated client" do
    let(:response) { post "/api/client", name: "test-create-client" }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.body).to include "Auth::Errors::TokenMissing"
    end
  end

  context "as an authenticated client without client:create scope" do
    let(:token) { client_token create_client }
    let(:response) do
      make_request token do
        post "/api/client", name: "test-create-client"
      end
    end

    it "fails with an appropriate code" do
      expect(response.status).to eq 403
    end

    it "fails with an appropriate error message" do
      expect(response.get([:errors, 0, :code])).to eq "InsufficientPrivileges"
    end
  end
end
