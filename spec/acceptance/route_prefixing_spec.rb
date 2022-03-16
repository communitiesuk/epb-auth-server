require "oauth2"
require "net/http"

describe "Acceptance: Using route prefixing with the server" do
  process_id = nil

  before(:all) do
    process =
      IO.popen(
        [{ "URL_PREFIX" => "/prefix" }, "rackup", "-q", { err: %i[child out] }],
      )
    process_id = process.pid

    sleep 2
  end

  after(:all) { Process.kill("KILL", process_id) }

  context "when using a prefix of /prefix" do
    it "the health check is accessible from /prefix/healthcheck" do
      uri = URI("http://localhost:9292/prefix/healthcheck")
      response = Net::HTTP.get_response(uri)

      expect(response.code).to eq "200"
    end
  end
end
