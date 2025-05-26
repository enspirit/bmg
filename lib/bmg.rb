require 'path'
require 'predicate'
require 'forwardable'
require 'set'
module Bmg

  require_relative 'bmg/version'
  require_relative 'bmg/error'
  require_relative 'bmg/support'
  require_relative 'bmg/algebra'
  require_relative 'bmg/type'
  require_relative 'bmg/summarizer'
  require_relative 'bmg/relation'
  require_relative 'bmg/operator'

  require_relative 'bmg/reader'
  require_relative 'bmg/writer'

  require_relative 'bmg/relation/empty'
  require_relative 'bmg/relation/in_memory'
  require_relative 'bmg/relation/spied'
  require_relative 'bmg/relation/materialized'
  require_relative 'bmg/relation/proxy'

  require_relative 'bmg/database'

  def main_spy
    @main_spy
  end
  module_function :main_spy

  def main_spy=(spy)
    @main_spy = spy
  end
  module_function :main_spy=

  # Add all factory methods
  extend Factory

  # Deprecated
  Leaf = Relation::InMemory
end
