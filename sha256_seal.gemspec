# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sha256_seal"
  spec.version       = File.read("VERSION.semver").chomp
  spec.author        = "Cyril Kato"
  spec.email         = "contact@cyril.email"
  spec.summary       = "Seal device with SHA-256 hash function."
  spec.description   = "Seal device with SHA-256 hash function, for Ruby."
  spec.homepage      = "https://github.com/cyril/sha256_seal.rb"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")
  spec.license       = "MIT"
  spec.files         = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "fix", ">= 1.0.0.beta4"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-md"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
