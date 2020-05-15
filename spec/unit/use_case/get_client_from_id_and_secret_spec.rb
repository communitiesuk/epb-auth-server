describe UseCase::GetClientFromIdAndSecret do
  context 'a client that exists' do
    describe 'a valid client id and secret' do
      let(:client_id) { '72d1d680-92ee-463a-98a8-f3e3973df038' }
      let(:client_secret) { 'test-client-secret' }

      it 'finds the client' do
        client = UseCase::GetClientFromIdAndSecret.new(Container.new)
                                                  .execute(
                                                    client_id,
                                                    client_secret
                                                  )

        expect(client.id).to eq client_id
      end
    end

    describe 'an invalid client id and secret' do
      let(:client_id) { '72d1d680-0000-463a-98a8-f3e3973df038' }
      let(:client_secret) { 'test-client-secret' }

      it 'returns a nil client' do
        client = UseCase::GetClientFromIdAndSecret.new(Container.new)
                                                  .execute(
                                                    client_id,
                                                    client_secret
                                                  )

        expect(client).to be_nil
      end
    end
  end
end
