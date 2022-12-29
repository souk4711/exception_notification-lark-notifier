# frozen_string_literal: true

require_relative "lib/exception_notification-lark-notifier/version"

Gem::Specification.new do |spec|
  spec.name = "exception_notification-lark-notifier"
  spec.version = ExceptionNotificationLarkNotifier::VERSION
  spec.authors = ["John Doe"]
  spec.email = ["johndoe@example.com"]

  spec.summary = "Lark notifier for exception notification gem."
  spec.description = "Lark notifier for exception notification gem."
  spec.homepage = "https://github.com/souk4711/exception_notification-lark-notifier"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/souk4711/exception_notification-lark-notifier"
  spec.metadata["changelog_uri"] = "https://github.com/souk4711/exception_notification-lark-notifier"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "exception_notification", "~> 4.0"
  spec.add_dependency "http", "~> 5.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
