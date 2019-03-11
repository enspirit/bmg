module Bmg
  module Sql
    Grammar = Sexpr.load(Path.dir/'grammar.sexp.yml')
    module Grammar

      def tagging_reference
        Sql
      end

      def default_tagging_module
        Expr
      end

    end # module Grammar
  end # module Sql
end # module Bmg
require_relative "nodes/expr"
require_relative "nodes/set_operator"
require_relative "nodes/literal"
require_relative "nodes/column_name"
require_relative "nodes/qualified_name"
require_relative "nodes/range_var_name"
require_relative "nodes/select_exp"
require_relative "nodes/set_quantifier"
require_relative "nodes/select_list"
require_relative "nodes/select_star"
require_relative "nodes/select_item"
require_relative "nodes/from_clause"
require_relative "nodes/table_as"
require_relative "nodes/native_table_as"
require_relative "nodes/subquery_as"
require_relative "nodes/table_name"
require_relative "nodes/group_by_clause"
require_relative "nodes/order_by_clause"
require_relative "nodes/order_by_term"
require_relative "nodes/limit_clause"
require_relative "nodes/offset_clause"
require_relative "nodes/union"
require_relative "nodes/intersect"
require_relative "nodes/except"
require_relative "nodes/with_exp"
require_relative "nodes/with_spec"
require_relative "nodes/name_intro"
require_relative "nodes/where_clause"
require_relative "nodes/cross_join"
require_relative "nodes/inner_join"
require_relative "nodes/summarizer"
