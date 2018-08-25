# Sha256Seal

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sha256_seal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sha256_seal

## Usage

Sign values and verify signatures of values.

## Example

In the context of a Web application, CSRF tokens could be embedded in URLs.

```ruby
secret  = 'secret'

value   = '/~bob/.__SIGNATURE_HERE__/documents/'
field   = '__SIGNATURE_HERE__'

builder = Sha256Seal::Builder.new(value, secret, field)
builder.signed_value  # => "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/"
builder.signed_value? # => false

value   = '/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/'
field   = '8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4'

builder = Sha256Seal::Builder.new(value, secret, field)
builder.signed_value  # => "/~bob/.8aa1d38b5c16d077d5ac1360c8a6f0248419ff5a3e6dca28a3233894ddcdf3c4/documents/"
builder.signed_value? # => true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyril/sha256_seal.rb.
