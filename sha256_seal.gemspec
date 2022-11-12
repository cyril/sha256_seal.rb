# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "sha256_seal"
  s.version       = ::File.read("VERSION.semver").chomp
  s.author        = "Cyril Kato"
  s.email         = "contact@cyril.email"
  s.summary       = "Seal device with SHA-256 hash function."
  s.description   = "Seal device with SHA-256 hash function, for Ruby."
  s.homepage      = "https://github.com/cyril/sha256_seal.rb"
  s.license       = "MIT"
  s.files         = ::Dir["LICENSE.md", "README.md", "lib/**/*"]

  s.required_ruby_version = ">= 3.1.2"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "r_spec"
  s.add_development_dependency "rubocop-gitlab-security"
  s.add_development_dependency "rubocop-md"
  s.add_development_dependency "rubocop-performance"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rspec"
  s.add_development_dependency "rubocop-thread_safety"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "yard"

  s.metadata["rubygems_mfa_required"] = "true"
end
