# frozen_string_literal: true

require 'oauth2'

describe 'OAuth Client Integration' do
  before(:all) do
    process = IO.popen(['rackup', '-q', err: %i[child out]])
    @process_id = process.pid

    sleep 1
  end

  after(:all) { Process.kill('KILL', @process_id) }

  context 'given an oauth client with valid credentials and an authenticated token' do
    let(:client) do
      OAuth2::Client.new 'test-client-id',
                         'test-client-secret',
                         site: 'http://localhost:9292'
    end

    let(:authenticated_client) do
      client.client_credentials.get_token
    end

    it 'is not expired' do
      expect(authenticated_client.expired?).to be_falsey
    end
  end
end
