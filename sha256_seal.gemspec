# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'sha256_seal'
  spec.version       = File.read('VERSION.semver').chomp
  spec.authors       = ['Cyril Kato']
  spec.email         = ['contact@cyril.email']

  spec.summary       = 'Seal device with SHA-256 hash function.'
  spec.description   = 'Seal device with SHA-256 hash function, for Ruby.'
  spec.homepage      = 'https://github.com/cyril/sha256_seal.rb'
  spec.license       = 'MIT'

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',    '~> 1.16'
  spec.add_development_dependency 'fix',        '~> 0.17'
  spec.add_development_dependency 'rake',       '~> 12.3'
  spec.add_development_dependency 'rubocop',    '~> 0.58'
  spec.add_development_dependency 'simplecov',  '~> 0.16'
  spec.add_development_dependency 'yard',       '~> 0.9'
end
