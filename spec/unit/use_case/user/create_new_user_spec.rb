describe UseCase::User::CreateNewUser do
  context "with valid user details" do
    describe "creating a new user" do
      let(:user_hash) do
        {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: Faker::Alphanumeric.alphanumeric(number: 16),
        }
      end

      let(:user) do
        described_class.new(Container.new).execute user_hash
      end

      it "has the right email" do
        expect(user.email).to eq user_hash[:email]
      end

      it "has the right name" do
        expect(user.name).to eq user_hash[:name]
      end

      it "does not return a password" do
        expect(user.password).to be_nil
      end
    end
  end

  context "with an invalid email address" do
    let(:user_hash) do
      {
        name: Faker::Name.name,
        email: "invalid-email",
        password: Faker::Alphanumeric.alphanumeric(number: 16),
      }
    end
  end
end
