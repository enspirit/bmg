require 'sequel'
require 'predicate/sequel'
module Bmg

  def sequel(dataset, type = Type::ANY)
    Sequel::Relation.new(type, dataset)
  end
  module_function :sequel

end
require_relative 'sequel/relation'
