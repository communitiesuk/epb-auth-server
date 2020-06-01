describe "Acceptance: Deleting a client" do
  context "as an authorised client" do
    describe "deleting a client" do
      let(:client) { create_client }
      let(:token) { create_token scopes: %w[client:delete client:fetch] }
      let(:delete_response) do
        make_request token do
          delete "/api/client/#{client.id}"
        end
      end

      it "the client is deleted" do
        expect(delete_response.status).to eq 200

        fetch_response = make_request token do
          get "/api/client/#{client.id}"
        end

        expect(fetch_response.status).to eq 404
      end
    end
  end

  context "as an unauthenticated client" do
    describe "deleting a client" do
      let(:response) { make_request { delete "/api/client/test" } }

      it "fails with an appropriate code" do
        expect(response.status).to eq 401
      end

      it "fails with an appropriate error message" do
        expect(response.get([:code])).to eq "NOT_AUTHENTICATED"
      end
    end
  end

  context "as an unauthorised client" do
    describe "deleting a client" do
      let(:response) do
        make_request create_token do
          delete "/api/client/test"
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
end
