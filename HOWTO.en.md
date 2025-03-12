# Sha256Seal Usage Guide

Sha256Seal is a small Ruby library that allows you to sign documents and verify their integrity. It uses HMAC-SHA-256 to generate secure cryptographic signatures.

## Core Concept

The fundamental concept of Sha256Seal is to replace a specific field in a string with a cryptographic signature. This signature is generated using:

1. The original string (with the field temporarily replaced by an empty string)
2. A secret key

## Common Use Cases

- Signing URLs to prevent tampering (anti-CSRF)
- Verifying data integrity
- Creating signed links with limited validity
- Protecting forms against modification

## Installation

```ruby
# In your Gemfile
gem "sha256_seal"

# Or via command line
gem install sha256_seal
```

## Basic Examples

### Signing a Document

When you want to sign a document, you need to include a placeholder field that will be replaced by the signature.

```ruby
require 'sha256_seal'

# Document with a signature placeholder
document = "/.__SIGNATURE__/accounts/42?editable=false"
secret = "my_secret_key"
placeholder = "__SIGNATURE__"

# Create a builder and sign the document
builder = Sha256Seal::Builder.new(document, secret, placeholder)

# Get the signed document
signed_document = builder.signed_value
# => "/.abc123def456.../accounts/42?editable=false"
```

### Verifying a Signed Document

To verify an already signed document, you need to know the secret key and provide the actual signature as the "field".

```ruby
require 'sha256_seal'

# Already signed document
signed_document = "/.abc123def456.../accounts/42?editable=false"
secret = "my_secret_key"
signature = "abc123def456..." # The signature extracted from the document

# Create a builder for verification
builder = Sha256Seal::Builder.new(signed_document, secret, signature)

# Check if the document is properly signed
if builder.signed_value?
  puts "Document is authentic ✓"
else
  puts "Document has been tampered with ✗"
end
```

## Rails Integration

### Initial Configuration

```ruby
# config/initializers/sha256_seal.rb
SIGNATURE_SECRET = ENV.fetch("SIGNATURE_SECRET_KEY", "default_dev_key_do_not_use_in_production")
```

### Rails Controller Example

```ruby
class SecureLinksController < ApplicationController
  def generate
    user_id = current_user.id
    timestamp = Time.now.to_i

    # Create a link with a signature placeholder
    unsigned_link = "/secure/__SIGNATURE__/resource/#{user_id}?t=#{timestamp}"

    # Sign the link
    builder = Sha256Seal::Builder.new(unsigned_link, SIGNATURE_SECRET, "__SIGNATURE__")
    @signed_link = builder.signed_value
  end

  def verify
    # Extract signature from path
    path_components = request.path.split('/')
    signature = path_components[2] # Assuming signature is the 3rd component

    # Verify the signature
    builder = Sha256Seal::Builder.new(request.original_url, SIGNATURE_SECRET, signature)

    if !builder.signed_value?
      render plain: "Invalid or expired link", status: :forbidden
      return
    end

    # Continue with normal processing if signature is valid
    # ...
  end
end
```

## Best Practices

1. **Store the secret key securely**: Use environment variables or a secrets manager.

2. **Use different keys for different types of data**: Don't reuse the same key for different contexts.

3. **Include temporal information**: For links or tokens that should expire, include a timestamp in the signed data.

4. **Limit data size**: Avoid signing very large strings.

5. **Include unique identifiers**: For example, include user IDs in the signed data to limit their usage.

## Technical Details

- Signatures are generated with HMAC-SHA-256
- The result is encoded in URL-safe Base64 without padding
- All strings are treated as UTF-8
- Maximum data size is limited to 1 MB

## Troubleshooting

### Signature Doesn't Match

Possible causes:
- The secret key has changed
- The document content has been modified
- The signature has been altered
- Incorrect character encoding

### ArgumentError: "field must appear exactly once"

This error occurs when:
- The signature field doesn't appear in the string
- The signature field appears multiple times

## Security

This library uses standard cryptographic algorithms (HMAC-SHA-256) but is not a substitute for comprehensive security measures. Use it as one security layer among others in your application.
