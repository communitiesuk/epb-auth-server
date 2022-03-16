describe "Acceptance: Creating a new user" do
  context "with an authenticated client" do
    let(:token) { client_token create_client scopes: %w[user:create] }

    describe "creating a new user" do
      let(:user_hash) do
        {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: Faker::Alphanumeric.alphanumeric(number: 16),
        }
      end
      let(:response) do
        make_request token do
          post "/api/user", user_hash.to_json, CONTENT_TYPE: "application/json"
        end
      end

      it "returns a created status" do
        expect(response.status).to eq 201
      end

      it "returns a valid user id" do
        expect(response.get(%i[data user id])).to be_a_valid_uuid
      end

      it "returns the right email" do
        expect(response.get(%i[data user email])).to eq user_hash[:email]
      end

      it "returns the right name" do
        expect(response.get(%i[data user name])).to eq user_hash[:name]
      end

      it "returns the right password" do
        expect(response.get(%i[data user password])).to be_nil
      end
    end

    describe "creating a new user with an invalid email address" do
      let(:user_hash) do
        {
          name: Faker::Name.name,
          email: "invalid-address",
          password: Faker::Alphanumeric.alphanumeric(number: 16),
        }
      end
      let(:response) do
        make_request token do
          post "/api/user", user_hash.to_json, CONTENT_TYPE: "application/json"
        end
      end

      it "returns a validation failure status" do
        expect(response.status).to eq 422
      end

      it "gives email invalid error code" do
        expect(response.get([:code])).to eq "VALIDATION_ERROR"
      end

      it "gives email invalid error message" do
        expect(response.get(%i[errors email])).to include "email of 'invalid-address' is an invalid email address"
      end
    end

    describe "creating a new user with an empty name" do
      let(:user_hash) do
        {
          email: "invalid-address",
          password: Faker::Alphanumeric.alphanumeric(number: 16),
        }
      end
      let(:response) do
        make_request token do
          post "/api/user", user_hash.to_json, CONTENT_TYPE: "application/json"
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
  end

  context "with an unauthenticated client" do
    let(:response) { make_request { post "/api/user" } }

    it "fails with an appropriate code" do
      expect(response.status).to eq 401
    end

    it "fails with an appropriate error message" do
      expect(response.get([:code])).to eq "NOT_AUTHENTICATED"
    end
  end

  context "with an authenticated client without user:create scope" do
    let(:response) do
      make_request client_token create_client do
        post "/api/user"
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
