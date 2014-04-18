# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'LodViewRewrite/version'

Gem::Specification.new do |spec|
  spec.name          = "LodViewRewrite"
  spec.version       = LodViewRewrite::VERSION
  spec.authors       = ["Hiroyuki Inoue"]
  spec.email         = ["mammymax@gmail.com"]
  spec.description   = %q{LodViewRewrite provides easy access to LOD.}
  spec.summary       = %q{You can define view of LOD and request to LOD simply.}
  spec.homepage      = "https://github.com/inohiro/LodViewRewrite"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sparql", "~> 1.1", "~> 1.1"
  spec.add_runtime_dependency "net-http-persistent", "~> 2.9"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  # spec.add_development_dependency "sparql", "~> 1.1"
  # spec.add_development_dependency "net-http-persistent", "~> 2.9"
end
