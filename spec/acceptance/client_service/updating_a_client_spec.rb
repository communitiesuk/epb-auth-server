describe "Acceptance: Updating a client" do
  let(:client) { create_client }

  describe "using the PUT endpoint" do
    context "when authorised" do
      let(:token) { create_token scopes: %w[client:update] }

      describe "updating a client" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  name: "updated-client-name",
                  scopes: %w[scope:three scope:four],
                  supplemental: { owner: "us" },
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
          expect(response.get(%i[data client supplemental])).to eq({ owner: "us" })
        end
      end

      describe "updating a client with empty supplemental" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  name: "updated-client-name",
                  scopes: %w[scope:three scope:four],
                  supplemental: nil,
                }.to_json,
                {
                  "CONTENT_TYPE" => "application/json",
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 200
        end
      end
    end

    context "when unauthenticated" do
      describe "updating a client" do
        let(:response) { put "/api/client/#{client.id}" }

        it "fails with an appropriate code" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when unauthorised" do
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

    context "when request body incorrectly formatted" do
      let(:token) { create_token scopes: %w[client:update] }

      describe "updating a client without a require field" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  scopes: %w[scope:three scope:four],
                  supplemental: { owner: "us" },
                }.to_json,
                {
                  "CONTENT_TYPE" => "application/json",
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/' did not contain a required property of 'name'"
        end
      end

      describe "updating a client with scopes in wrong format" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  name: "updated-client-name",
                  scopes: "scope:three scope:four",
                  supplemental: { owner: "us" },
                }.to_json,
                {
                  "CONTENT_TYPE" => "application/json",
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/scopes' of type string did not match the following type: array"
        end
      end

      describe "updating a client with missing scopes" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  name: "updated-client-name",
                  scopes: nil,
                  supplemental: { owner: "us" },
                }.to_json,
                {
                  "CONTENT_TYPE" => "application/json",
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/scopes' of type null did not match the following type: array"
        end
      end

      describe "updating a client with incorrectly wrapped json" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  client:
                    {
                      id: "#{client.id}",
                      scopes: %w[scope:three scope:four],
                      supplemental: nil,
                    },

                }.to_json,
                {
                  "CONTENT_TYPE" => "application/json",
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/' did not contain a required property of 'id'"
        end
      end

      describe "updating a client without json" do
        let(:response) do
          make_request token do
            put "/api/client/#{client.id}",
                {
                  id: "#{client.id}",
                  scopes: "scope:three scope:four",
                  supplemental: { owner: "us" },
                }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 400
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end
      end
    end
  end

  describe "using the PATCH endpoint" do
    context "when authorised" do
      let(:token) { create_token scopes: %w[client:update] }

      describe "adding scopes to a client" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "add",
                    scopes: %w[scope:three scope:four],
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an updated status" do
          expect(response.status).to eq 200
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
      end

      describe "removing scopes from a client" do
        let(:client) { create_client scopes: %w[scope:one scope:two] }
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "remove",
                    scopes: %w[scope:one],
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an updated status" do
          expect(response.status).to eq 200
        end

        it "returns an updated list of scopes" do
          expect(response.get(%i[data client scopes])).to eq %w[scope:two]
        end
      end
    end

    context "when unauthenticated" do
      describe "updating a client" do
        let(:response) { patch "/api/client/#{client.id}" }

        it "fails with an appropriate code" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when unauthorised" do
      let(:token) { create_token }

      describe "updating a client" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}"
          end
        end

        it "tells the user they are not authorised" do
          expect(response.status).to eq 403
        end
      end
    end

    context "when request body incorrectly formatted" do
      let(:token) { create_token scopes: %w[client:update] }

      describe "updating a client without a require field" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    scopes: %w[scope:one],
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/' did not contain a required property of 'op'"
        end
      end

      describe "updating a client with scopes in wrong format" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "add",
                    scopes: "scope:three",
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/scopes' of type string did not match the following type: array"
        end
      end

      describe "updating a client with missing scopes" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "add",
                    scopes: nil,
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/scopes' of type null did not match the following type: array"
        end
      end

      describe "updating a client with incorrect operator" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "delete",
                    scopes: %w[scope:one],
                  }.to_json,
                  {
                    "CONTENT_TYPE" => "application/json",
                  }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 422
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end

        it "gives name invalid error message" do
          expect(response.body[:errors].first[:title]).to eq "JSON failed schema validation. Error: The property '#/op' value \"delete\" did not match the regex '(?:add|remove)'"
        end
      end

      describe "updating a client without json" do
        let(:response) do
          make_request token do
            patch "/api/client/#{client.id}",
                  {
                    op: "add",
                    scopes: %w[scope:one],
                  }
          end
        end

        it "returns an error" do
          expect(response.status).to eq 400
        end

        it "gives name invalid error code" do
          expect(response.body[:errors].first[:code]).to eq "INVALID_REQUEST"
        end
      end
    end
  end
end
