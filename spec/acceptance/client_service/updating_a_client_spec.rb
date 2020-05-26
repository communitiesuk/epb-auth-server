# frozen_string_literal: true

describe "Acceptance: Updating a client" do
  let(:client) { create_client }

  context "as an authorised client" do
    let(:token) { create_token scopes: %w[client:update] }

    describe "updating a client" do
      let(:response) do
        make_request token do
          put "/api/client/#{client.id}",
              {
                name: "updated-client-name",
                scopes: %w[scope:three scope:four],
                supplemental: { test: false },
              }.to_json,
              {
                "CONTENT_TYPE" => "application/json",
              }
        end
      end

      it "returns an updated status" do
        expect(response.status).to eq 200
      end

      it "returns the name correctly" do
        expect(response.get(%i[data client name])).to eq "updated-client-name"
      end

      it "returns a valid client id" do
        expect(response.get(%i[data client id])).to be_a_valid_uuid
      end

      it "returns no client secret" do
        expect(response.get(%i[data client secret])).to be_nil
      end

      it "returns an updated list of scopes" do
        expect(response.get(%i[data client scopes])).to eq %w[scope:three scope:four]
      end

      it "returns updated supplemental data" do
        expect(response.get(%i[data client supplemental])).to eq({ test: false })
      end
    end
  end

  context "as an unauthenticated client" do
    describe "updating a client" do
      let(:response) { put "/api/client/#{client.id}" }

      it "fails with an appropriate code" do
        expect(response.status).to eq 401
      end
    end
  end

  context "as an unauthorised client" do
    let(:token) { create_token }

    describe "updating a client" do
      let(:response) do
        make_request token do
          put "/api/client/#{client.id}"
        end
      end

      it "tells the user they are not authorised" do
        expect(response.status).to eq 403
      end
    end
  end
end
