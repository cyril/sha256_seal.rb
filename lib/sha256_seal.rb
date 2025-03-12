# frozen_string_literal: true

require 'openssl'
require 'base64'

# Namespace for the Sha256Seal library.
#
# @example Basic usage
#   # Sign a document with a placeholder
#   document = "/.__SIGNATURE__/accounts/42?editable=false"
#   secret = "my_secret_key"
#   signature_field = "__SIGNATURE__"
#
#   # Create a builder and sign the document
#   builder = Sha256Seal::Builder.new(document, secret, signature_field)
#   signed_document = builder.signed_value
#   # => "/.abc123def456.../accounts/42?editable=false"
#
#   # Verify a signed document
#   builder = Sha256Seal::Builder.new(signed_document, secret, "abc123def456...")
#   builder.signed_value? # => true
module Sha256Seal
  # The Builder class provides functionality to sign data with HMAC-SHA-256 and verify signatures.
  # It replaces a placeholder field in a string with a Base64 URL-safe encoded HMAC-SHA-256 signature.
  #
  # @example Signing a URL with a placeholder
  #   url = "https://example.com/__SIGNATURE__/resource/42"
  #   builder = Sha256Seal::Builder.new(url, "secret_key", "__SIGNATURE__")
  #   signed_url = builder.signed_value
  #   # => "https://example.com/abc123def456.../resource/42"
  #
  # @example Verifying a signed URL
  #   signed_url = "https://example.com/abc123def456.../resource/42"
  #   builder = Sha256Seal::Builder.new(signed_url, "secret_key", "abc123def456...")
  #   builder.signed_value? # => true if the signature is valid
  class Builder
    # The hashing algorithm used for signature generation
    HASH_ALGORITHM = 'sha256'.freeze

    # The digest instance for the hashing algorithm
    HASH_DIGEST = ::OpenSSL::Digest.new(HASH_ALGORITHM).freeze

    # Maximum allowed size for input values (1 MB)
    MAX_VALUE_SIZE = 1024 * 1024

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
    # @raise [ArgumentError] If value, secret, or field is empty
    # @raise [ArgumentError] If value, secret, or field contains invalid UTF-8 characters
    # @raise [ArgumentError] If value size exceeds MAX_VALUE_SIZE
    #
    # @example Creating a builder for signing
    #   # With placeholder in the document
    #   builder = Sha256Seal::Builder.new("/.__SIGNATURE__/path", "secret", "__SIGNATURE__")
    #
    # @example Creating a builder for verification
    #   # With actual signature in the document
    #   builder = Sha256Seal::Builder.new("/.abc123def456.../path", "secret", "abc123def456...")
    def initialize(value, secret, field)
      @value  = String(value).dup.force_encoding('UTF-8')
      @secret = String(secret).dup.force_encoding('UTF-8')
      @field  = String(field).dup.force_encoding('UTF-8')

      raise ::ArgumentError, "Value cannot be empty" if @value.empty?
      raise ::ArgumentError, "Secret cannot be empty" if @secret.empty?
      raise ::ArgumentError, "Field cannot be empty" if @field.empty?

      raise ::ArgumentError, "Value contains invalid UTF-8 characters" unless @value.valid_encoding?
      raise ::ArgumentError, "Secret contains invalid UTF-8 characters" unless @secret.valid_encoding?
      raise ::ArgumentError, "Field contains invalid UTF-8 characters" unless @field.valid_encoding?

      raise ::ArgumentError, "Value too large" if @value.bytesize > MAX_VALUE_SIZE

      @field_regexp = ::Regexp.new(::Regexp.escape(@field))

      raise ::ArgumentError, "#{@field.inspect} must appear exactly once." unless @value.scan(@field_regexp).length == 1

      freeze
    end

    # Returns a signed version of the value, with the field replaced by the calculated signature.
    #
    # @return [String] The value with the field replaced by the signature
    #
    # @example Signing a document
    #   document = "/.__SIGN_HERE__/user/profile"
    #   builder = Sha256Seal::Builder.new(document, "my_secret", "__SIGN_HERE__")
    #   signed_document = builder.signed_value
    #   # => "/.abc123def456.../user/profile"
    def signed_value
      value.gsub(field, signature)
    end

    # Checks if the current value is properly signed.
    #
    # @return [Boolean] true if the field in the value matches the expected signature
    #
    # @example Verifying a signed document
    #   signed_doc = "/.abc123def456.../user/profile"
    #   builder = Sha256Seal::Builder.new(signed_doc, "my_secret", "abc123def456...")
    #   if builder.signed_value?
    #     puts "Document is authentic"
    #   else
    #     puts "Document has been tampered with"
    #   end
    def signed_value?
      if defined?(::ActiveSupport::SecurityUtils)
        ::ActiveSupport::SecurityUtils.secure_compare(signature, field)
      else
        signature.eql?(field)
      end
    end

    private

    # Calculates the HMAC-SHA-256 signature based on the salted value and encodes it in Base64 URL-safe format.
    #
    # @return [String] The Base64 URL-safe encoded HMAC-SHA-256 signature without padding
    def signature
      urlsafe_base64_hmac(secret, salt_value)
    end

    # Creates a salted version of the value by temporarily replacing the field with an empty string.
    # This prevents leakage of the secret in the signature verification process.
    #
    # @return [String] The value with the field replaced by an empty string
    def salt_value
      value.gsub(@field_regexp, '')
    end

    # Generates a URL-safe Base64 encoded HMAC-SHA-256 signature for the given message.
    #
    # @param key [String] The secret key for HMAC
    # @param message [String] The message to sign
    # @return [String] The Base64 URL-safe encoded HMAC-SHA-256 signature without padding
    def urlsafe_base64_hmac(key, message)
      hmac_digest = ::OpenSSL::HMAC.digest(HASH_DIGEST, key, message)
      ::Base64.urlsafe_encode64(hmac_digest, padding: false)
    end
  end
end
