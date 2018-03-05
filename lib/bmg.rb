require 'path'
require 'predicate'
module Bmg

  def csv(path, options = {})
    Relation.new Reader::Csv.new path, options
  end
  module_function :csv

  def excel(path, options = {})
    Relation.new Reader::Excel.new path, options
  end
  module_function :excel

end
require_relative 'bmg/version'
require_relative 'bmg/error'
require_relative 'bmg/algebra'
require_relative 'bmg/type'
require_relative 'bmg/relation'
require_relative 'bmg/leaf'
require_relative 'bmg/operator'
require_relative 'bmg/reader'
