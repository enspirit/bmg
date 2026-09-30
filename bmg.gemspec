$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'bmg/version'

Gem::Specification.new do |s|
  s.name        = 'bmg'
  s.version     = Bmg::VERSION
  s.summary     = "Bmg is Alf's successor."
  s.description = "Bmg is Alf's relational algebra for ruby, but much simpler and lighter than Alf itself"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['LICENSE.md', 'Gemfile','Rakefile', '{bin,lib,tasks,examples}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://github.com/enspirit/bmg'
  s.license     = 'MIT'

  s.required_ruby_version = ">= 2.7"

  s.metadata = {
    "source_code_uri"   => "https://github.com/enspirit/bmg",
    "changelog_uri"     => "https://github.com/enspirit/bmg/blob/master/CHANGELOG.md",
    "bug_tracker_uri"   => "https://github.com/enspirit/bmg/issues",
    "documentation_uri" => "https://www.relational-algebra.dev/"
  }

  s.add_dependency "predicate", ">= 2.7.1", "< 3.0"
  s.add_dependency "path", ">= 2.0", "< 3.0"

  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3.6"
  s.add_development_dependency "roo", ">= 2.8", "< 4.0"
  s.add_development_dependency "write_xlsx", "~> 1.0"
  s.add_development_dependency "sequel", "~> 5.0"
  s.add_development_dependency "sqlite3", ">= 1.4", "< 3.0"
  s.add_development_dependency "activesupport", ">= 6.0", "< 9.0"
  # No longer a default gem as of ruby 3.5/4.0, but still used by the specs
  s.add_development_dependency "ostruct", ">= 0.2", "< 1.0"
  s.add_development_dependency "benchmark-ips", "~> 2.14"
end
