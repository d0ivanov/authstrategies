# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authstrategies/version'

Gem::Specification.new do |spec|
  spec.name          = "authstrategies"
  spec.version       = Authstrategies::VERSION
  spec.authors       = ["Dobromir Ivanov"]
  spec.email         = ["dobromir0ivanov@gmail.com"]
  spec.description   = %q{Warden implementation for Sinatra.}
  spec.summary       = %q{Warden implementation for Sinatra.}
  spec.homepage      = "https://github.com/d0ivanov/authstrategies"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "lib/authstrategies"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rspec-instafail"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "sqlite3"

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "bcrypt"
  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "sinatra-activerecord"
end
