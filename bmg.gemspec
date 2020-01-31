$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'bmg/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'bmg'
  s.version     = Bmg::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Bmg is Alf's successor."
  s.description = "Bmg is Alf's relational algebra for ruby, but much simpler and lighter than Alf itself"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['LICENSE.md', 'Gemfile','Rakefile', '{bin,lib,tasks,examples}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://github.com/enspirit/bmg'
  s.license     = 'MIT'

  s.add_dependency "predicate", "~> 2.2", ">= 2.2.1"

  s.add_development_dependency "rake", "~> 10"
  s.add_development_dependency "rspec", "~> 3.6"
  s.add_development_dependency "path", ">= 1.3"
  s.add_development_dependency "roo", ">= 2.7"
  s.add_development_dependency "sequel"
  s.add_development_dependency "sqlite3"
end
