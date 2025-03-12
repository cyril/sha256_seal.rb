# frozen_string_literal: false

require_relative "../spec_helper"

RSpec.describe Sha256Seal::Builder do
  subject do
    described_class.new(value, secret, field)
  end

  context "when secret is 'secret'" do
    let(:secret) do
      "secret"
    end

    context "when value is not signed" do
      let(:value) do
        "/~bob/.__SIGNATURE_HERE__/documents/"
      end

      context "when the field corresponds to an entry" do
        let(:field) do
          "__SIGNATURE_HERE__"
        end

        it { expect(subject.signed_value).to eq "/~bob/.vWTJTrUClmSCXslUPW9dk2X5fujpbbqPG5AChKRpiGQ/documents/" }
        it { expect(subject.signed_value?).to be false }
      end

      context "when the field does not correspond to any entry" do
        let(:field) do
          "vWTJTrUClmSCXslUPW9dk2X5fujpbbqPG5AChKRpiGQ"
        end

        it { expect { subject.signed_value }.to raise_exception ::ArgumentError }
        it { expect { subject.signed_value? }.to raise_exception ::ArgumentError }
      end
    end

    context "when value is signed" do
      let(:value) do
        "/~bob/.vWTJTrUClmSCXslUPW9dk2X5fujpbbqPG5AChKRpiGQ/documents/"
      end

      context "when the field corresponds to an entry" do
        let(:field) do
          "vWTJTrUClmSCXslUPW9dk2X5fujpbbqPG5AChKRpiGQ"
        end

        it { expect(subject.signed_value).to eq "/~bob/.vWTJTrUClmSCXslUPW9dk2X5fujpbbqPG5AChKRpiGQ/documents/" }
        it { expect(subject.signed_value?).to be true }
      end
    end

    context "when value has more than one unsigned field" do
      let(:value) do
        "/~bob/.__SIGNATURE_HERE__/__SIGNATURE_HERE__/documents/"
      end

      context "when the field corresponds to more than one entry" do
        let(:field) do
          "__SIGNATURE_HERE__"
        end

        it { expect { subject.signed_value }.to raise_exception ::ArgumentError }
        it { expect { subject.signed_value? }.to raise_exception ::ArgumentError }
      end
    end

    context "when handling different input types" do
      let(:value) do
        123
      end

      let(:field) do
        "123"
      end

      it "converts numeric value to string" do
        expect(subject.signed_value).to eq "-eZuF5tnR65UEI-C-K3os8Jddv0wr95sOVgixTAZYWk"
        expect(subject.signed_value?).to be false
      end
    end

    context "when handling empty values" do
      let(:value) do
        "/~bob/./documents/"
      end

      let(:field) do
        ""
      end

      it { expect { subject.signed_value }.to raise_exception ::ArgumentError }
    end

    context "when changing the secret" do
      let(:value) do
        "/~bob/.__SIGNATURE_HERE__/documents/"
      end

      let(:field) do
        "__SIGNATURE_HERE__"
      end

      it "generates different signatures with different secrets" do
        signature1 = subject.signed_value

        # Create a new instance with a different secret
        signature2 = described_class.new(value, "different_secret", field).signed_value

        expect(signature1).not_to eq(signature2)
      end
    end
  end

  # Test the complete workflow with a realistic example
  context "when using in a real-world scenario" do
    let(:secret) { "csrf_secret_token" }

    it "signs and verifies a URL properly" do
      # Step 1: Generate a URL with a placeholder
      original_url = "/accounts/42?editable=false&csrf=__PLACEHOLDER__"

      # Step 2: Sign the URL
      builder = described_class.new(original_url, secret, "__PLACEHOLDER__")
      signed_url = builder.signed_value

      # Extract the generated signature
      signature = signed_url.match(/csrf=([a-zA-Z0-9_-]+)/)[1]

      # Step 3: Verify the signed URL
      verifier = described_class.new(signed_url, secret, signature)

      # The URL should be valid
      expect(verifier.signed_value?).to be true

      # Step 4: Tamper with the URL
      tampered_url = signed_url.gsub("editable=false", "editable=true")
      tampered_verifier = described_class.new(tampered_url, secret, signature)

      # The tampered URL should be invalid
      expect(tampered_verifier.signed_value?).to be false
    end
  end

  # Add new tests for UTF-8 encoding handling
  context "when handling UTF-8 characters" do
    let(:secret) { "secret_key" }

    it "properly handles UTF-8 characters in values" do
      # Unicode test with emojis and accented characters
      value = "/users/🔑/résumé/.__SIGNATURE__/"
      field = "__SIGNATURE__"

      builder = described_class.new(value, secret, field)
      signed_value = builder.signed_value

      # Extract the signature
      signature = signed_value.match(/\/users\/🔑\/résumé\/\.([a-zA-Z0-9_-]+)\//)[1]

      # Verify the signature
      verifier = described_class.new(signed_value, secret, signature)
      expect(verifier.signed_value?).to be true
    end

    it "rejects invalid UTF-8 sequences" do
      # Create an invalid UTF-8 sequence
      invalid_utf8 = "/users/\xFF\xFE/.__SIGNATURE__/".force_encoding('UTF-8')
      field = "__SIGNATURE__"

      expect {
        described_class.new(invalid_utf8, secret, field)
      }.to raise_exception(ArgumentError)
    end
  end

  # Test maximum size limits
  context "when handling large inputs" do
    let(:secret) { "secret_key" }
    let(:field) { "__SIGNATURE__" }

    it "rejects values exceeding the maximum size" do
      # Create a string just over the MAX_VALUE_SIZE limit
      large_value = "/path/__SIGNATURE__/" + "x" * (Sha256Seal::Builder::MAX_VALUE_SIZE)

      expect {
        described_class.new(large_value, secret, field)
      }.to raise_exception(ArgumentError)
    end
  end
end
