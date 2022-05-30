require 'path'
require 'predicate'
require 'forwardable'
require 'set'
module Bmg

  def mutable(enumerable, type = Type::ANY)
    Relation::InMemory::Mutable.new(type, enumerable).spied(main_spy)
  end
  module_function :mutable

  def in_memory(enumerable, type = Type::ANY)
    Relation::InMemory.new(type, enumerable).spied(main_spy)
  end
  module_function :in_memory

  def text_file(path, options = {}, type = Type::ANY)
    Reader::TextFile.new(type, path, options).spied(main_spy)
  end
  module_function :text_file

  def csv(path, options = {}, type = Type::ANY)
    Reader::Csv.new(type, path, options).spied(main_spy)
  end
  module_function :csv

  def excel(path, options = {}, type = Type::ANY)
    Reader::Excel.new(type, path, options).spied(main_spy)
  end
  module_function :excel

  def main_spy
    @main_spy
  end
  module_function :main_spy

  def main_spy=(spy)
    @main_spy = spy
  end
  module_function :main_spy=

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

  # Deprecated
  Leaf = Relation::InMemory
end
