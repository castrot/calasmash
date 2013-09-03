# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'calasmash/version'

Gem::Specification.new do |spec|
  spec.name          = "calasmash"
  spec.version       = Calasmash::VERSION
  spec.authors       = ["Alex Fish"]
  spec.email         = ["fish@ustwo.co.uk"]
  spec.description   = "A gift for Juan"
  spec.summary       = "Compile an app, run sinatra, point the app at sinatra, run the app tests with calabash"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.executables << "calasmash"
end
