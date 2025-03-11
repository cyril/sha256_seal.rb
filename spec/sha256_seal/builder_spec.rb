# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Sha256Seal::Builder do
  subject do
    described_class.new(value, secret, field)
  end

  context "when secret is 'secret'" do
    let(:secret) do
      'secret'
    end

    context 'when value is not signed' do
      let(:value) do
        '/~bob/.__SIGNATURE_HERE__/documents/'
      end

      context 'when the field corresponds to an entry' do
        let(:field) do
          '__SIGNATURE_HERE__'
        end

        it { expect(subject.signed_value).to eq '/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/' }
        it { expect(subject.signed_value?).to be false }
      end

      context 'when the field do not correspond to any entry' do
        let(:field) do
          '8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4'
        end

        it { expect { subject.signed_value }.to raise_exception ArgumentError }
        it { expect { subject.signed_value? }.to raise_exception ArgumentError }
      end
    end

    context 'when value is signed' do
      let(:value) do
        '/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/'
      end

      context 'when the field corresponds to an entry' do
        let(:field) do
          '8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4'
        end

        it { expect(subject.signed_value).to eq '/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/' }
        it { expect(subject.signed_value?).to be true }
      end
    end

    context 'when value has more than one unsigned field' do
      let(:value) do
        '/~bob/.__SIGNATURE_HERE__/__SIGNATURE_HERE__/documents/'
      end

      context 'when the field corresponds to more than one entry' do
        let(:field) do
          '__SIGNATURE_HERE__'
        end

        it { expect { subject.signed_value }.to raise_exception ArgumentError }
        it { expect { subject.signed_value? }.to raise_exception ArgumentError }
      end
    end
  end
end
