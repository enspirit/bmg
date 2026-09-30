$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'bmg/version'

Gem::Specification.new do |s|
  s.name        = 'bmg-redis'
  s.version     = Bmg::VERSION
  s.summary     = "Expose redis as relations."
  s.description = "bmg-redis provides an adapter to expose redis databases as relations"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,tasks}/**/*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://github.com/enspirit/bmg'
  s.license     = 'MIT'

  s.required_ruby_version = ">= 2.7"

  s.metadata = {
    "source_code_uri" => "https://github.com/enspirit/bmg",
    "changelog_uri"   => "https://github.com/enspirit/bmg/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/enspirit/bmg/issues"
  }

  s.add_dependency "bmg", "= #{Bmg::VERSION}"
  s.add_dependency "redis", ">= 4.0", "< 7.0"

  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3.6"
end
