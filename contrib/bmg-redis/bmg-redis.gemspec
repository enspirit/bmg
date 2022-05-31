$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'bmg/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'bmg-redis'
  s.version     = Bmg::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Expose redis as relations."
  s.description = "bmg-redis provides an adapter to expose redis databases as relations"
  s.authors     = ["Bernard Lambeau"]
  s.email       = 'blambeau@gmail.com'
  s.files       = Dir['Gemfile', 'Rakefile', '{lib,tasks}/**/*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://github.com/enspirit/bmg-redis'
  s.license     = 'MIT'

  s.add_dependency "bmg", "= #{Bmg::VERSION}"
  s.add_dependency "redis", ">= 4.0", "< 5.0"

  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3.6"
end
