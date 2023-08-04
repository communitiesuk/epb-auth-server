describe "CORS behaviour for allowing calls from API docs" do
  context "when sending a response when API docs URL is not set in environment" do
    let(:response) { options "/api/schemes" }

    it "has no Access-Control-Allow-Origin header" do
      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end

  context "when sending a response on most endpoints when API docs URL is set in environment" do
    let(:docs_url) { "http://epb-api-docs/" }
    let(:response) { options "/api/schemes" }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("EPB_API_DOCS_URL").and_return(docs_url)
    end

    it "has no Access-Control-Allow-Origin header" do
      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end

  context "when sending a response on most endpoints when API docs URL is not set in environment" do
    let(:response) { post "/oauth/token" }

    it "has no Access-Control-Allow-Origin header" do
      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end

  context "when sending a response from the OAuth token endpoint when API docs URL is set in environment" do
    let(:docs_url) { "http://epb-api-docs/" }
    let(:response) { post "/oauth/token" }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("EPB_API_DOCS_URL").and_return(docs_url)
    end

    it "has an Access-Control-Allow-Origin header set to the docs URL" do
      # expect(response.status).to eq 303
      expect(response.headers["Access-Control-Allow-Origin"]).to eq docs_url
    end

    it "has a Vary header set to Origin" do
      expect(response.headers["Vary"]).to eq "Origin"
    end

    it "has an Access-Control-Allow-Credentials header set to true" do
      expect(response.headers["Access-Control-Allow-Credentials"]).to eq "true"
    end
  end
end
