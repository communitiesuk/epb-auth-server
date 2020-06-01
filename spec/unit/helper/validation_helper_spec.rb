describe Helper::ValidationHelper do
  context "with a field that cannot be empty" do
    describe "a field with text" do
      it "passes validation" do
        expect(described_class.new.validate(
                 { text: %w[not_empty] }, { text: "test" }
               )).to be_nil
      end
    end

    describe "an empty field" do
      let(:validation) do
        [{ text: %w[not_empty] }, { text: "" }]
      end

      it "raises a validation error" do
        expect {
          described_class.new.validate(*validation)
        }.to raise_error Boundary::ValidationError
      end

      it "returns an error saying the text field was empty" do
        def errors
          described_class.new.validate(*validation)
        rescue Boundary::ValidationError => e
          e.errors
        end

        expect(errors[:text]).to include "text cannot be empty"
      end
    end

    describe "an unset field" do
      let(:validation) do
        [{ text: %w[not_empty] }, {}]
      end

      it "raises a validation error" do
        expect {
          described_class.new.validate(*validation)
        }.to raise_error Boundary::ValidationError
      end

      it "returns an error saying the text field was empty" do
        def errors
          described_class.new.validate(*validation)
        rescue Boundary::ValidationError => e
          e.errors
        end

        expect(errors[:text]).to include "text cannot be empty"
      end
    end
  end

  context "with an email address" do
    describe "a valid email address" do
      it "passes validation" do
        expect(described_class.new.validate(
                 { email: %w[email] }, { email: "test@example.com" }
               )).to be_nil
      end
    end

    describe "an invalid email address" do
      let(:validation) do
        [{ email: %w[email] }, { email: "invalid-email" }]
      end

      it "raises a validation error" do
        expect {
          described_class.new.validate(*validation)
        }.to raise_error Boundary::ValidationError
      end

      it "returns an error saying the email address was invalid" do
        def errors
          described_class.new.validate(*validation)
        rescue Boundary::ValidationError => e
          e.errors
        end

        expect(errors[:email]).to include "email of 'invalid-email' is an invalid email address"
      end
    end
  end
end
