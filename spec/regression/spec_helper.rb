require 'rspec'
require 'bmg'
require 'bmg/sequel'
require 'path'
require 'yaml'
require 'ostruct'

module SpecHelper
end

RSpec.configure do |c|
  c.include SpecHelper
end
