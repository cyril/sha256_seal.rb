# Sha256 Seal 🔏

A tiny library to sign documents, and check their integrity.

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
SECRET = 'secret'


document_string = '/.__SIGNATURE_HERE__/accounts/42?editable=false'
signature_field = '__SIGNATURE_HERE__'

builder = Sha256Seal::Builder.new(document_string, SECRET, signature_field)
builder.signed_value? # => false
builder.signed_value  # => "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false"


document_string = '/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false'
signature_field = 'a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db'

builder = Sha256Seal::Builder.new(document_string, SECRET, signature_field)
builder.signed_value? # => true
builder.signed_value  # => "/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=false"


document_string = '/.a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db/accounts/42?editable=true'
signature_field = 'a31c3936f236684a8ebc51dcfef168ce124450d71ae1ec404552ec9e0090a8db'

builder = Sha256Seal::Builder.new(document_string, SECRET, signature_field)
builder.signed_value? # => false
builder.signed_value  # => "/.babd3a90b6bc2a4c0c7536a0c4804e5430a5a6df27d223c0f0102edb231de590/accounts/42?editable=true"
```

### Rails integration example

Environment variable:

```txt
CSRF_SECRET_KEY=secret
```

Route:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  scope module: :verified_requests, path: '.:csrf', as: 'verified_request' do
    get '/accounts/:id', to: 'accounts#show', as: 'account'
  end
end
```

Controller:

```ruby
# app/controllers/verified_requests/base_controller.rb
class VerifiedRequests::BaseController < ApplicationController
  # @see https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html#method-i-verified_request-3F
  def verified_request?
    secret          = ENV.fetch('CSRF_SECRET_KEY')
    document_string = request.original_url.force_encoding('utf-8')
    signature_field = request.path_parameters.fetch(:csrf)

    builder = Sha256Seal::Builder.new(document_string, secret, signature_field)
    builder.signed_value? || Rails.env.test?
  end

  def signed_url(route_method, **options)
    url_route_method  = "#{route_method}_url".to_sym
    incorrect_csrf    = '__CSRF_SECRET_KEY__'
    url_route_string  = public_send(url_route_method, csrf: incorrect_csrf, **options)

    replace_incorrect_csrf_by_correct_csrf(url_route_string, incorrect_csrf: incorrect_csrf)
  end
  helper_method :signed_url

  def replace_incorrect_csrf_by_correct_csrf(value, incorrect_csrf:)
    secret  = ENV.fetch('CSRF_SECRET_KEY')
    field   = incorrect_csrf
    builder = Sha256Seal::Builder.new(value, secret, field)
    value   = builder.signed_value
    field   = builder.send(:signature)
    builder = Sha256Seal::Builder.new(value, secret, field)

    builder.signed_value
  end
end
```

View:

```erb
# app/views/verified_requests/accounts/show.html.erb

<%
  signed_url(:verified_request_account, id: 'bob', admin: true) # => "http://0.0.0.0:5000/.405d7c8f14389c9ae7f1d97ff66699093bf2d89d13b4f4280a35d62f9e616259/accounts/bob?admin=true"
%>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyril/sha256_seal.rb.
