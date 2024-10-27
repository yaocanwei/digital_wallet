# digital_wallet.gemspec
require_relative 'lib/digital_wallet/version'

Gem::Specification.new do |spec|
  spec.name          = "digital_wallet"
  spec.version       = DigitalWallet::VERSION
  spec.authors       = ["cheney"]
  spec.email         = ["a1248014498@gmail.com"]

  spec.summary       = %q{A simple digital wallet system}
  spec.description   = %q{A Ruby library that provides digital wallet functionality with support for deposits, withdrawals, and transfers}
  spec.homepage      = "https://github.com/yaocanwei/digital_wallet"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.glob('{lib,test}/**/*') + ['LICENSE.txt', 'README.md', 'Rakefile', 'digital_wallet.gemspec']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
