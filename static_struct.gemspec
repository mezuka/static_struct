# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'static_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "static_struct"
  spec.version       = StaticStruct::VERSION
  spec.authors       = ["Mezuka LLC"]
  spec.email         = ["mezuka@mezuka.com"]

  spec.summary       = %q{Convert hashes into static objects.}
  spec.description   = %q{An OpenStruct-like library but with the static-like behavior.
                          I.e. it's not possible to call undefined methods.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
