module Bmg
  module Sql
    module Support
      class FromClauseOrderer

        # Takes a from_clause AST as input and generates an relationally
        # equivalent list of (type,table,predicate) triplets, where:
        #
        # - type is :base, :cross_join or :inner_join
        # - table is table_as, native_table_as or subquery_as
        # - predicate is a join predicate
        #
        # The types are observed in strict increasing order
        # (one :base, zero or more :cross_join, zero or more
        # :inner_join). The list is such that it can be safely
        # written as an expression of the following SQL form:
        #
        #     t1                            # [ :base, t1, nil ]
        #     cross_join t2                 # [ :cross_join, t2, nil ]
        #     cross_join t3                 # [ :cross_join, t3, nil ]
        #     inner_join t4 ON p4           # [ :inner_join, t4, p4 ]
        #     inner_join t5 ON p5           # [ :inner_join, t5, p5 ]
        #
        # A NotImplementedError may be raised if no linearization can
        # be found.
        #
        def call(sexpr)
          tables, joins = collect(sexpr)
          order_all(tables, joins)
        end

      protected

        def order_all(tables, joins, result = [])
          if tables.empty? and joins.empty?
            result
          elsif tables.empty?
            raise NotImplementedError, "Orphan joins: `#{joins.inspect}`"
          else
            table, tables_tail = tables.first, tables[1..-1]
            on, joins_tail = split_joins(joins, table, tables_tail)
            join_kind = result.empty? ? :base : (on.empty? ? :cross_join : :inner_join)
            predicate = on.inject(nil){|p,clause|
              p.nil? ? clause : Predicate::Factory.and(p, clause)
            }
            clause = [ join_kind, table, predicate ]
            order_all(tables_tail, joins_tail, result + [clause])
          end
        end

        def split_joins(joins, table, tables_tail)
          joins.partition{|j|
            uses?(j, table) && !tables_tail.find{|t|
              uses?(j, t)
            }
          }
        end

      protected

        def collect(sexpr)
          tables = []
          joins  = []
          _collect(sexpr, tables, joins)
          tables.sort!{|t1,t2|
            t1js = joins.select{|j| uses?(j, t1) }.size
            t2js = joins.select{|j| uses?(j, t2) }.size
            t1js == 0 ? (t2js == 0 ? 0 : -1) : (t2js == 0 ? 1 : 0)
          }
          [ tables, joins ]
        end

        def _collect(sexpr, tables, joins)
          case sexpr.first
          when :from_clause
            _collect(sexpr.table_spec, tables, joins)
          when :table_as, :native_table_as, :subquery_as
            tables << sexpr
          when :inner_join
            _collect_joins(sexpr.predicate, joins)
            _collect(sexpr.left, tables, joins)
            _collect(sexpr.right, tables, joins)
          when :cross_join
            _collect(sexpr.left, tables, joins)
            _collect(sexpr.right, tables, joins)
          end
        end

        def _collect_joins(sexpr, joins)
          case sexpr.first
          when :and
            _collect_joins(sexpr[1], joins)
            _collect_joins(sexpr[2], joins)
          when :eq
            joins << sexpr
          else
            raise NotImplementedError, "Unexpected predicate `#{sexpr.inspect}`"
          end
        end

        def uses?(join, table)
          name = table.as_name.to_s
          left_name = var_name(join[1])
          right_name = var_name(join[2])
          (left_name == name) or (right_name == name)
        end

        def var_name(qualified)
          case qualified.first
          when :qualified_identifier then qualified[1].to_s
          when :qualified_name       then qualified[1][1].to_s
          else
            raise NotImplementedError, "Unexpected qualified name `#{qualified.inspect}`"
          end
        end

      end # class FromClauseOrderer
    end # module Support
  end # module Sql
end # module Bmg
