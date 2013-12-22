# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authstrategies/version'

Gem::Specification.new do |spec|
  spec.name          = "authstrategies"
  spec.version       = Authstrategies::VERSION
  spec.authors       = ["Dobromir Ivanov"]
  spec.email         = ["dobromir0ivanov@gmail.com"]
  spec.description   = %q{AuthStrategies is a Warden implementation for sinatra. For now it only implements a password strategy.}
  spec.summary       = %q{Warden implementation for Sinatra}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

	spec.add_runtime_dependency "sinatra"
	spec.add_runtime_dependency "sinatra-activerecord"
	spec.add_runtime_dependency "activerecord"
	spec.add_runtime_dependency "warden"
	spec.add_runtime_dependency "bcrypt-ruby"
	spec.add_runtime_dependency "rack"
	spec.add_runtime_dependency "rack-flash3", '1.0.1', require: 'rack/flash'

end
