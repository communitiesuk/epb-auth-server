require "base64"

describe "Acceptance: OAuth token service" do
  context "with valid client credentials" do
    context "in the header" do
      describe "generating a new token" do
        let(:client) { create_client scopes: %w[scope:one scope:two], supplemental: { test: true } }
        let(:response) { request_token client.id, client.secret }
        let(:token) do
          processor = Auth::TokenProcessor.new ENV["JWT_SECRET"], ENV["JWT_ISSUER"]
          processor.process response.get(%i[access_token])
        end

        it "gives a status of 200" do
          expect(response.status).to eq 200
        end

        it "gives a response with a valid jwt based access_token" do
          expect(response.get(%i[access_token])).to be_a_valid_jwt_token
        end

        it "gives a response with a token that expires at least an hour in the future" do
          expect(response.get(%i[expires_in])).to be >= 3_600
        end

        it "gives a response with a token of type Bearer" do
          expect(response.get(%i[token_type])).to eq "bearer"
        end

        it "gives a token with scopes" do
          expect(token.scopes?(%w[scope:one scope:two])).to be_truthy
        end

        it "gives a token with supplemental data" do
          expect(token.supplemental("test")).to eq true
        end
      end
    end

    context "in the request body" do
      describe "generating a new token" do
        let(:client) { create_client scopes: %w[scope:one scope:two], supplemental: { test: true } }
        let(:response) do
          make_request do
            post "/oauth/token", client_id: client.id, client_secret: client.secret
          end
        end
        let(:token) do
          processor = Auth::TokenProcessor.new ENV["JWT_SECRET"], ENV["JWT_ISSUER"]
          processor.process response.get(%i[access_token])
        end

        it "gives a status of 200" do
          expect(response.status).to eq 200
        end

        it "gives a response with a valid jwt based access_token" do
          expect(response.get(%i[access_token])).to be_a_valid_jwt_token
        end

        it "gives a response with a token that expires at least an hour in the future" do
          expect(response.get(%i[expires_in])).to be >= 3_600
        end

        it "gives a response with a token of type Bearer" do
          expect(response.get(%i[token_type])).to eq "bearer"
        end

        it "gives a token with scopes" do
          expect(token.scopes?(%w[scope:one scope:two])).to be_truthy
        end

        it "gives a token with supplemental data" do
          expect(token.supplemental("test")).to eq true
        end
      end
    end
  end

  context "with invalid client credentials" do
    context "in the header" do
      describe "generating a new token" do
        let(:response) { request_token "invalid-client", "invalid-secret" }
        it "gives a status of 401" do
          expect(response.status).to eq 401
        end
      end
    end

    context "in the request body" do
      describe "generating a new token" do
        let(:response) do
          make_request do
            post "/oauth/token",
                 client_id: "invalid-client",
                 client_secret: "invalid-secret"
          end
        end
        it "gives a status of 401" do
          expect(response.status).to eq 401
        end
      end
    end
  end
end
