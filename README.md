# Sha256 Seal 🔏

A small Ruby library for signing documents and verifying their integrity using HMAC-SHA-256.

## Status

[![Version](https://img.shields.io/github/v/tag/cyril/sha256_seal.rb?label=Version&logo=github)](https://github.com/cyril/sha256_seal.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/cyril/sha256_seal.rb/main)
[![Ruby](https://github.com/cyril/sha256_seal.rb/workflows/Ruby/badge.svg?branch=main)](https://github.com/cyril/sha256_seal.rb/actions?query=workflow%3Aruby+branch%3Amain)
[![License](https://img.shields.io/github/license/cyril/sha256_seal.rb?label=License&logo=github)](https://github.com/cyril/sha256_seal.rb/raw/main/LICENSE.md)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "sha256_seal"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install sha256_seal
```

## Overview

Sha256Seal enables you to:

1. Sign data by inserting a cryptographic signature at a specific location in a string
2. Verify the integrity of the signed data

The core concept is simple: replace a placeholder field in a string with an HMAC-SHA-256 signature, calculated using a secret key. This signature ensures that the data cannot be tampered with without detection.

## Usage Examples

### Basic Example - Signing Data

To sign a document, create a new builder with:
- The original string containing a placeholder
- A secret key
- The placeholder to be replaced with the signature

```ruby
document = "/.__SIGNATURE__/accounts/42?editable=false"
secret = "my_secret_key"
placeholder = "__SIGNATURE__"

builder = Sha256Seal::Builder.new(document, secret, placeholder)
signed_document = builder.signed_value
# => "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false"
```

### Verifying Signed Data

To verify a signed document:

```ruby
signed_document = "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false"
secret = "my_secret_key"
signature = "a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db"

builder = Sha256Seal::Builder.new(signed_document, secret, signature)
is_valid = builder.signed_value?
# => true if the signature is valid, false otherwise
```

### Tamper Detection

If the document is altered in any way after signing, verification will fail:

```ruby
# Original signed document
signed_document = "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false"

# Tampered document (changed editable=false to editable=true)
tampered_document = "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=true"
signature = "a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db"

builder = Sha256Seal::Builder.new(tampered_document, secret, signature)
builder.signed_value? # => false
```

## Rails Integration Example

Here's a practical example of how Sha256Seal can be integrated with Rails for CSRF protection in URLs:

```ruby
# Environment variable
CSRF_SECRET_KEY = ENV.fetch("CSRF_SECRET_KEY", "your_default_development_secret")

# In routes.rb
Rails.application.routes.draw do
  scope module: :verified_requests, path: ".:csrf", as: "verified_request" do
    get "/accounts/:id", to: "accounts#show", as: "account"
  end
end

# In app/controllers/verified_requests/base_controller.rb
module VerifiedRequests
  class BaseController < ::ApplicationController
    def signed_url(route_method, **options)
      # Generate a URL with a temporary placeholder
      url_route_method = "#{route_method}_url".to_sym
      placeholder = "__CSRF_TOKEN__"
      url_string = public_send(url_route_method, csrf: placeholder, **options)

      # Replace the placeholder with a real signature
      builder = Sha256Seal::Builder.new(url_string, CSRF_SECRET_KEY, placeholder)
      builder.signed_value
    end
    helper_method :signed_url

    # In a before_action filter, verify the request's signature
    def verified_request?
      signature = request.path_parameters.fetch(:csrf)
      document_string = request.original_url.force_encoding("utf-8")

      builder = Sha256Seal::Builder.new(document_string, CSRF_SECRET_KEY, signature)
      builder.signed_value? || Rails.env.test?
    end
  end
end
```

## Common Use Cases

- Protecting against CSRF attacks by signing URLs
- Creating signed download links with limited validity
- Verifying the integrity of data submitted in forms
- Creating tamper-proof API request signatures

## Technical Details

- Uses HMAC-SHA-256 for cryptographic signatures
- Encodes signatures as URL-safe Base64 without padding
- Ensures UTF-8 encoding for all input strings
- Limits maximum input size to 1MB

## Versioning

Sha256Seal uses [Semantic Versioning 2.0.0](https://semver.org/)

## Further Reading

For more information about the concepts behind URL protection using HMAC, check out this article:
[URL Protection Through HMAC: A Practical Approach](https://blog.cyril.email/posts/2025-03-12/url-protection-through-hmac.html)

## License

The [gem](https://rubygems.org/gems/sha256_seal) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
