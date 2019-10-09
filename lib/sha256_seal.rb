# frozen_string_literal: true

require 'digest/sha2'

# Namespace for the Sha256Seal library.
module Sha256Seal
  # Main class for the Sha256Seal library.
  class Builder
    attr_reader :value, :secret, :field

    def initialize(value, secret, field)
      @value  = value.to_s
      @secret = secret.to_s
      @field  = field.to_s

      i = @value.scan(@field).length

      return if i.equal?(1)

      raise ::ArgumentError, "#{i} #{@field.inspect} occurrences instead of 1."
    end

    def signed_value
      value.gsub(field, signature)
    end

    def signed_value?
      signature.eql?(field)
    end

    private

    def signature
      ::Digest::SHA256.hexdigest(salt_value)
    end

    def salt_value
      value.gsub(field, secret)
    end
  end
end
