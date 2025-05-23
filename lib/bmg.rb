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

  def json(path, options = {}, type = Type::ANY)
    in_memory(path.load.map{|tuple| TupleAlgebra.symbolize_keys(tuple) })
  end
  module_function :json

  def yaml(path, options = {}, type = Type::ANY)
    in_memory(path.load.map{|tuple| TupleAlgebra.symbolize_keys(tuple) })
  end
  module_function :yaml

  def excel(path, options = {}, type = Type::ANY)
    Reader::Excel.new(type, path, options).spied(main_spy)
  end
  module_function :excel

  def generate(*args, &bl)
    Bmg::Relation.generate(*args, &bl)
  end
  module_function :generate

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

  require_relative 'bmg/database'

  # Deprecated
  Leaf = Relation::InMemory
end
