# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'verlane/version'

Gem::Specification.new do |spec|
  spec.name          = "verlane"
  spec.version       = Verlane::VERSION
  spec.authors       = ["Mikko Kokkonen"]
  spec.email         = ["mikko@owlforestry.com"]
  spec.description   = %q{Simple version number management library, using Rake tasks}
  spec.summary       = %q{Manage version numbers}
  spec.homepage      = "https://github.com/owlforestry/verlane"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "versionomy"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
