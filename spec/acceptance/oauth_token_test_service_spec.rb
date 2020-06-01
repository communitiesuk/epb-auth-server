describe "Acceptance: OAuth token test service" do
  context "with a valid token" do
    describe "testing a token" do
      let(:token) do
        create_token id: "test",
                     scopes: %w[scope:one scope:two],
                     supplemental: { test: true }
      end
      let(:response) do
        make_request token do
          get "/oauth/token/test"
        end
      end

      it "gives a status of 200" do
        expect(response.status).to eq 200
      end

      it "gives a response with the expected subject" do
        expect(response.get(%i[data subject])).to eq "test"
      end
    end
  end

  context "without a token" do
    describe "testing a token" do
      let(:response) { make_request { get "/oauth/token/test" } }

      it "gives a status of 401" do
        expect(response.status).to eq 401
      end
    end
  end
end
