# frozen_string_literal: true

require_relative "lib/ccru/version"

Gem::Specification.new do |spec|
  spec.name = "ccru"
  spec.version = Ccru::VERSION
  spec.authors = ["thucpt"]
  spec.email = ["thucpt@zigexn.vn"]

  spec.summary = "Multi-language linter wrapper that checks only changed lines/files (Ruby, JavaScript, ERB)"
  spec.description = "Checks only new files fully and modified files only for changed lines based on git diff.\
  Supports Ruby (RuboCop), JavaScript (ES6 syntax + code quality), and ERB templates (conventions)."
  spec.homepage = "https://github.com/thuczige/ccru"
  spec.required_ruby_version = ">= 2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/thuczige/ccru"
  spec.metadata["changelog_uri"] = "https://github.com/thuczige/ccru/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  File.basename(__FILE__)
  spec.files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "rubocop", ">= 0.5", "< 2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
