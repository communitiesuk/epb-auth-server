describe "Integration: Migrating client secrets to use hashes" do
  before(:context) do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    system("rake db:migrate VERSION=20200519113852")
    ActiveRecord::Base.connection.execute(
      "INSERT INTO clients (name, secret)
       VALUES ('test-client', 'test-secret')",
    )
    system("rake db:migrate")
  end

  before do
    allow(Helper::Toggles).to receive(:enabled?)
  end

  context "when migrating from plaintext to hashed secrets" do
    describe "using the correct authentication details" do
      let(:migrated_client) { Gateway::ClientGateway.new.fetch name: "test-client" }
      let(:response) { request_token migrated_client.id, "test-secret" }

      it "gives a status of 200" do
        expect(response.status).to eq 200
      end

      it "gives a response with a valid jwt based access_token" do
        expect(response.get(%i[access_token])).to be_a_valid_jwt_token
      end

      it "gives a response with a token that expires at most fifteen minutes into the future" do
        expect(response.get(%i[expires_in])).to be <= 900
      end

      it "gives a response with a token of type Bearer" do
        expect(response.get(%i[token_type])).to eq "bearer"
      end
    end

    describe "using incorrect authentication details" do
      let(:migrated_client) { Gateway::ClientGateway.new.fetch name: "test-client" }
      let(:response) { request_token migrated_client.id, "invalid-secret" }

      it "gives a status of 401" do
        expect(response.status).to eq 401
      end
    end
  end
end
