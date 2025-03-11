# frozen_string_literal: true

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

        it { expect(subject.signed_value).to eq "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/" }
        it { expect(subject.signed_value?).to be false }
      end

      context "when the field do not correspond to any entry" do
        let(:field) do
          "8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4"
        end

        it { expect { subject.signed_value }.to raise_exception ::ArgumentError }
        it { expect { subject.signed_value? }.to raise_exception ::ArgumentError }
      end
    end

    context "when value is signed" do
      let(:value) do
        "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/"
      end

      context "when the field corresponds to an entry" do
        let(:field) do
          "8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4"
        end

        it { expect(subject.signed_value).to eq "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/" }
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

    # Additional tests for edge cases
    context "when handling different input types" do
      let(:value) do
        123
      end

      let(:field) do
        "123"
      end

      it "converts numeric value to string" do
        expect(subject.signed_value).to eq "2bb80d537b1da3e38bd30361aa855686bde0eacd7162fef6a25fe97bf527a25b"
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
      signature = signed_url.match(/csrf=([a-f0-9]+)/)[1]

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
end
