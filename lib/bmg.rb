require 'path'
module Bmg

  def csv(path, options = {})
    Relation.new Reader::Csv.new path, options
  end
  module_function :csv

end
require_relative 'bmg/version'
require_relative 'bmg/operator'
require_relative 'bmg/relation'
require_relative 'bmg/reader'
