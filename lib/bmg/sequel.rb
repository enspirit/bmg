require 'bmg/sql'
require 'sequel'
require 'predicate/sequel'
module Bmg

  module Sequel

    def sequel(*args, &bl)
      source, sequel_db, type = sequel_params(*args, &bl)
      if type
        builder = Sql::Builder.new
        sexpr = builder.select_all(type.to_attrlist, source)
        Sequel::Relation.new(type, builder, sexpr, sequel_db).spied(Bmg.main_spy)
      else
        Bmg::Relation.new(source)
      end
    end
    module_function :sequel

    def sequel_params(source, sequel_db = nil, type = nil)
      sequel_db, type = nil, sequel_db if sequel_db.nil? or sequel_db.is_a?(Type)
      sequel_db = source.db if sequel_db.nil? and source.is_a?(::Sequel::Dataset)
      raise ArgumentError, "A Sequel::Database object is required" if sequel_db.nil?
      raise ArgumentError, "Type's attrlist must be known (#{type})" if type && !type.knows_attrlist?
      type = infer_type(sequel_db, source) if type.nil?
      [source, sequel_db, type]
    end
    module_function :sequel_params

    def infer_type(sequel_db, source)
      TypeInference.new(sequel_db).call(source) if source.is_a?(Symbol)
    end
    module_function :infer_type

  end

  # Builds a Relation that uses Sequel for managing real data
  # accesses.
  #
  # Supported signatures:
  #
  #   # Table name, providing the Sequel's Database object
  #   Bmg.sequel(:suppliers, DB)
  #
  #   # Sequel dataset object, embedding the Database object
  #   # `from_self` will be used at compilation time, you don't
  #   # need to call it yourself.
  #   Bmg.sequel(DB[:suppliers])
  #
  #   # Similar, but with with a pure SQL query
  #   Bmg.sequel(DB[%Q{SELECT ... FROM ...}])
  #
  #   # All signatures above with an explicit type object, e.g.:
  #   Bmg.sequel(:suppliers, DB, Type::ANY)
  #   Bmg.sequel(DB[:suppliers], Type::ANY)
  #
  def sequel(source, sequel_db = nil, type = nil)
    Sequel.sequel(source, sequel_db, type)
  end
  module_function :sequel

end
require_relative 'sequel/ext'
require_relative 'sequel/translator'
require_relative 'sequel/type_inference'
require_relative 'sequel/relation'
