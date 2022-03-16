describe "Acceptance: Creating a new client" do
  context "when authenticated" do
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
        expect(response.get(%i[data client scopes])).to be_empty
      end

      it "returns no supplemental data" do
        expect(response.get(%i[data client supplemental])).to be_empty
      end
    end

    describe "creating a client without a name" do
      let(:response) do
        make_request token do
          post "/api/client",
               {}.to_json,
               CONTENT_TYPE: "application/json"
        end
      end

      it "returns a validation failure status" do
        expect(response.status).to eq 422
      end

      it "gives name invalid error code" do
        expect(response.get([:code])).to eq "VALIDATION_ERROR"
      end

      it "gives name invalid error message" do
        expect(response.get(%i[errors name])).to include "name cannot be empty"
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

  context "when not authenticated" do
    let(:response) { make_request { post "/api/client" } }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.get([:code])).to eq "NOT_AUTHENTICATED"
    end
  end

  context "when authenticated without client:create scope" do
    let(:response) do
      make_request create_token do
        post "/api/client"
      end
    end

    it "fails with an appropriate code" do
      expect(response.status).to eq 403
    end

    it "fails with an appropriate error message" do
      expect(response.get([:code])).to eq "NOT_AUTHORIZED"
    end
  end
end
