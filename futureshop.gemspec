require_relative "lib/futureshop/version"

Gem::Specification.new do |spec|
  spec.name          = "futureshop"
  spec.version       = Futureshop::VERSION
  spec.authors       = ["Kitaiti Makoto"]
  spec.email         = ["KitaitiMakoto@gmail.com"]

  spec.summary       = "futureshop APIv2 client and tools"
  spec.description   = "futureshop APIv2 client and tools"
  spec.homepage      = "https://gitlab.com/KitaitiMakoto/futureshop"
  spec.required_ruby_version = ">= 2.7.0"
  spec.license       = "AGPL-3.0-or-later"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://gitlab.com/KitaitiMakoto/futureshop/-/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "test-unit-rr"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
