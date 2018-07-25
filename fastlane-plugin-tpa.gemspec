# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/tpa/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-tpa'
  spec.version       = Fastlane::Tpa::VERSION
  spec.author        = %q{Morten Bøgh}
  spec.email         = %q{morten@justabeech.com}

  spec.summary       = %q{TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more}
  spec.homepage      = "https://github.com/ThePerfectApp/fastlane-plugin-tpa"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client', '~> 2.0.2'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.100.1')
end
