$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'bmg/version'

Gem::Specification.new do |s|
  s.name        = 'bmg'
  s.version     = Bmg::VERSION
  s.date        = '2017-11-20'
  s.summary     = "Bmg is Alf's successor."
  s.description = "Bmg is Alf's relational algebra for ruby, but much simpler and lighter than Alf itself"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['LICENSE.md', 'Gemfile','Rakefile', '{bin,lib,spec,tasks,examples}/**/*', 'README*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://github.com/enspirit/bmg'
  s.license     = 'MIT'

  s.add_development_dependency "rake", "~> 10"
  s.add_development_dependency "rspec", "~> 3.6"
  s.add_development_dependency "path", ">= 1.3"
  s.add_development_dependency "roo", ">= 2.7"
end
