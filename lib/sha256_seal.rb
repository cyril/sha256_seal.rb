# frozen_string_literal: true

require 'digest/sha2'

# Namespace for the Sha256Seal library.
module Sha256Seal
  # The Builder class provides functionality to sign data with SHA-256 and verify signatures.
  # It works by replacing a placeholder field in a string with a SHA-256 hash signature.
  class Builder
    # @return [String] The value containing the field to be signed or verified
    attr_reader :value

    # @return [String] The secret key used for generating the signature
    attr_reader :secret

    # @return [String] The field or placeholder to be replaced with the signature
    attr_reader :field

    # Initializes a new Builder instance for signing or verifying data.
    #
    # @param value [#to_s] The string value containing the field to be signed or verified
    # @param secret [#to_s] The secret key used for creating the signature
    # @param field [#to_s] The field or placeholder to be replaced with the signature
    #
    # @raise [ArgumentError] If the field doesn't appear exactly once in the value
    def initialize(value, secret, field)
      @value  = value.to_s
      @secret = secret.to_s
      @field  = field.to_s

      i = @value.scan(@field).length

      return if i.equal?(1)

      raise ::ArgumentError, "#{i} #{@field.inspect} occurrences instead of 1."
    end

    # Returns a signed version of the value, with the field replaced by the calculated signature.
    #
    # @return [String] The value with the field replaced by the signature
    # @example
    #   builder = Sha256Seal::Builder.new("/.__SIGNATURE__/path", "secret", "__SIGNATURE__")
    #   builder.signed_value # => "/.a1b2c3d4.../path"
    def signed_value
      value.gsub(field, signature)
    end

    # Checks if the current value is properly signed.
    #
    # @return [Boolean] true if the field in the value matches the expected signature
    # @example
    #   builder = Sha256Seal::Builder.new("/.a1b2c3d4.../path", "secret", "a1b2c3d4...")
    #   builder.signed_value? # => true
    def signed_value?
      signature.eql?(field)
    end

    private

    # Calculates the SHA-256 hash signature based on the salted value.
    #
    # @return [String] The hex-encoded SHA-256 hash digest
    # @api private
    def signature
      ::Digest::SHA256.hexdigest(salt_value)
    end

    # Creates a salted version of the value by temporarily replacing the field with the secret.
    # This is the value that will be hashed to create the signature.
    #
    # @return [String] The value with the field replaced by the secret
    # @api private
    def salt_value
      value.gsub(field, secret)
    end
  end
end
