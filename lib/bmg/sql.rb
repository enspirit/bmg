require 'sexpr'
module Bmg

  module Sql

    class NotSupportedError < Bmg::Error; end

  end # module Sql

  def sql(table, type = Type::ANY)
    builder = Sql::Builder.new
    sexpr = builder.select_star_from(table)
    Sql::Relation.new(type, builder, sexpr).spied(main_spy)
  end
  module_function :sql

end # module Bmg
require_relative 'sql/ext/predicate'
require_relative 'sql/grammar'
require_relative 'sql/processor'
require_relative 'sql/builder'
require_relative 'sql/dialect'
require_relative 'sql/relation'
require_relative 'sql/support/from_clause_orderer'
