require 'rspec'
require 'bmg'
require 'bmg/sequel'
require 'path'

module SpecHelper
  SEQUEL_DB = Sequel.connect("sqlite://#{Path.dir.parent}/suppliers-and-parts.db")

  def sequel_db
    SEQUEL_DB
  end
end

RSpec.configure do |c|
  c.include SpecHelper
end
