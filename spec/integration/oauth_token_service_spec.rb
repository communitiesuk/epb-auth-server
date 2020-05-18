# frozen_string_literal: true

require "oauth2"
require "net/http"

describe "OAuth Client Integration" do
  before(:all) do
    process = IO.popen(["rackup", "-q", err: %i[child out]])
    @process_id = process.pid

    sleep 2
  end

  after(:all) { Process.kill("KILL", @process_id) }

  context "given an oauth client with valid credentials and an authenticated token" do
    let(:client) do
      OAuth2::Client.new "72d1d680-92ee-463a-98a8-f3e3973df038",
                         "test-client-secret",
                         site: "http://localhost:9292"
    end

    let(:authenticated_client) { client.client_credentials.get_token }

    it "is not expired" do
      expect(authenticated_client.expired?).to be_falsey
    end

    it "can be used to make a request" do
      expect {
        @response = authenticated_client.get("http://localhost:9292/oauth/token/test")
      }.to_not raise_error

      expect(@response.body).to eq '{"message":"ok"}'
    end
  end

  context "given a http client is not authenticated" do
    it "cannot be used to make a request to a secured route" do
      uri = URI("http://localhost:9292/oauth/token/test")
      response = Net::HTTP.get_response(uri)

      expect(response).to be_an_instance_of Net::HTTPUnauthorized
    end
  end
end
