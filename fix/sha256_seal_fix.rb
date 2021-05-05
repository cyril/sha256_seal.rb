# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "sha256_seal")

require "fix"

# rubocop:disable Metrics/BlockLength
Fix.describe Sha256Seal::Builder do
  on :new, "/~bob/.__SIGNATURE_HERE__/documents/", "secret", "__SIGNATURE_HERE__" do
    on :signed_value do
      it { MUST eql "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/" }
    end

    on :signed_value? do
      it { MUST equal false }
    end
  end

  on :new, "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/", "secret",
     "8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4" do
    on :signed_value do
      it { MUST eql "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/" }
    end

    on :signed_value? do
      it { MUST equal true }
    end
  end

  on :new, "/~bob/.__SIGNATURE_HERE__/documents/", "secret",
     "8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4" do
    on :signed_value do
      it { MUST raise_exception ::ArgumentError }
    end

    on :signed_value? do
      it { MUST raise_exception ::ArgumentError }
    end
  end

  on :new, "/~bob/.__SIGNATURE_HERE__/__SIGNATURE_HERE__/documents/", "secret", "__SIGNATURE_HERE__" do
    on :signed_value do
      it { MUST raise_exception ::ArgumentError }
    end

    on :signed_value? do
      it { MUST raise_exception ::ArgumentError }
    end
  end
end
# rubocop:enable Metrics/BlockLength
