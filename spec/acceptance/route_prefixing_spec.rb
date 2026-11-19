require "oauth2"
require "net/http"

describe "Acceptance: Using route prefixing with the server" do
  include_context "with a server", { "URL_PREFIX" => "/prefix" }

  context "when using a prefix of /prefix" do
    it "the health check is accessible from /prefix/healthcheck" do
      uri = URI("#{server_url}/prefix/healthcheck")
      response = Net::HTTP.get_response(uri)

      expect(response.code).to eq "200"
    end
  end
end
