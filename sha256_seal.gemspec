# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'sha256_seal'
  s.version       = File.read('VERSION.semver').chomp
  s.author        = 'Cyril Kato'
  s.email         = 'contact@cyril.email'
  s.summary       = 'Seal device with SHA-256 hash function.'
  s.description   = 'Seal device with SHA-256 hash function, for Ruby.'
  s.homepage      = 'https://github.com/cyril/sha256_seal.rb'
  s.license       = 'MIT'
  s.files         = Dir['LICENSE.md', 'README.md', 'lib/**/*']

  s.required_ruby_version = '>= 3.4.2'

  s.add_runtime_dependency 'openssl', '~> 3.3'
  s.add_runtime_dependency 'base64', '~> 0.2'

  s.metadata['rubygems_mfa_required'] = 'true'
end
