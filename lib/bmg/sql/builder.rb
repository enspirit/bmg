module Bmg
  module Sql
    class Builder

      DISTINCT     = Grammar.sexpr([:set_quantifier, "distinct"])
      ALL          = Grammar.sexpr([:set_quantifier, "all"])
      IS_TABLE_DEE = Grammar.sexpr([:select_list,
                                     [:select_item,
                                       [:literal, true],
                                       [:column_name, "is_table_dee"]]])

      def self.builder(meth)
        old = instance_method(meth)
        define_method(meth) do |*args, &bl|
          Grammar.sexpr(old.bind(self).call(*args, &bl))
        end
      end

      def initialize(start = 0)
        @next_qualifier = (start || 0)
      end

      def distinct
        DISTINCT
      end
      builder :distinct

      def all
        ALL
      end
      builder :all

      def name_intro(name, sexpr)
        [:name_intro, table_name(name), sexpr]
      end
      builder :name_intro

      def select_star_from(name, qualifier = next_qualifier!)
        [ :select_exp,
          all,
          select_star(qualifier),
          from_clause(name, qualifier) ]
      end
      builder :select_star_from

      def select_all(heading, name, qualifier = next_qualifier!)
        [ :select_exp, all,
          select_list(heading, qualifier),
          from_clause(name, qualifier) ]
      end
      builder :select_all

      def select_is_table_dee(subquery)
        [ :select_exp, all, is_table_dee,
          [:where_clause, exists(subquery)] ]
      end
      builder :select_is_table_dee

      def is_table_dee
        IS_TABLE_DEE
      end
      builder :is_table_dee

      def select_list(attrs, qualifier)
        attrs = attrs.to_attr_list if attrs.respond_to?(:to_attr_list)
        attrs.map{|a| select_item(qualifier, a) }.unshift(:select_list)
      end
      builder :select_list

      def select_item(qualifier, name, as = name)
        [:select_item,
          qualified_name(qualifier, name.to_s),
          column_name(as.to_s)]
      end
      builder :select_item

      def select_star(qualifier = next_qualifier!)
        [:select_star, [:range_var_name, qualifier]]
      end
      builder :select_star

      def from_clause(table, qualifier)
        arg = case table
        when String, Symbol  then table_as(table, qualifier)
        when Expr            then subquery_as(table, qualifier)
        else                      native_table_as(table, qualifier)
        end
        [ :from_clause, arg ]
      end
      builder :from_clause

      def table_as(table, qualifier)
        table = case table
                when String, Symbol then table_name(table)
                else table
                end
        [:table_as,
          table,
          range_var_name(qualifier) ]
      end
      builder :table_as

      def subquery_as(subquery, qualifier)
        [:subquery_as,
          subquery,
          range_var_name(qualifier) ]
      end
      builder :table_as

      def native_table_as(table, qualifier)
        [ :native_table_as,
          table,
          range_var_name(qualifier) ]
      end

      def qualified_name(qualifier, name)
        [:qualified_name,
          range_var_name(qualifier),
          column_name(name) ]
      end
      builder :qualified_name

      def range_var_name(qualifier)
        [:range_var_name, qualifier]
      end
      builder :range_var_name

      def column_name(name)
        [:column_name, name]
      end
      builder :column_name

      def table_name(name)
        [:table_name, name]
      end
      builder :table_name

      def exists(subquery)
        Predicate::Grammar.sexpr [ :exists, subquery ]
      end

      def order_by_clause(ordering, &desaliaser)
        ordering.to_a.map{|(name,direction)|
          name = name.to_s
          name = (desaliaser && desaliaser[name]) || column_name(name)
          [:order_by_term, name, direction ? direction.to_s : "asc"]
        }.unshift(:order_by_clause)
      end
      builder :order_by_clause

      def limit_clause(limit)
        [:limit_clause, limit]
      end
      builder :limit_clause

      def offset_clause(limit)
        [:offset_clause, limit]
      end
      builder :offset_clause

      def from_self(sexpr)
        Processor::FromSelf.new(self).call(sexpr)
      end

    public

      def last_qualifier
        "t#{@next_qualifier}"
      end

      def next_qualifier!
        "t#{@next_qualifier += 1}"
      end

    end
  end
end
