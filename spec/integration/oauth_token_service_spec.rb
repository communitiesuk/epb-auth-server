require "oauth2"
require "net/http"

describe "Integration: OAuth Client" do
  include_context "with a server"

  context "with an authenticated client" do
    let(:client) { create_client }
    let(:authenticated_client) do
      OAuth2::Client.new(
        client.id,
        client.secret,
        site: server_url,
      ).client_credentials.get_token
    end

    it "is not expired" do
      expect(authenticated_client).not_to be_expired
    end

    describe "making a request" do
      let(:response) { authenticated_client.get("#{server_url}/oauth/token/test") }
      let(:body) { JSON.parse response.body, symbolize_names: true }

      it "returns a successful response" do
        expect(response.status).to eq 200
      end

      it "gives a response with the expected subject" do
        expect(body[:data][:subject]).to eq client.id
      end
    end
  end

  context "with an unauthenticated client" do
    describe "making a request" do
      let(:response) do
        Net::HTTP.get_response URI("#{server_url}/oauth/token/test")
      end

      it "cannot be used to make a request" do
        expect(response).to be_an_instance_of Net::HTTPUnauthorized
      end
    end
  end
end
