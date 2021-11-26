module Bmg
  module Sql
    module Support
      class FromClauseOrderer

        # Given a `from_clause` AST as input, e.g.
        #
        #     [ :from_clause,
        #       [ :cross_join
        #         [ :inner_join,
        #           [ :inner_join,
        #             [ :table_as, "suppliers", "s"  ],
        #             [ :table_as, "supplies",  "sp" ],
        #             [ :eq, [ :qualified, "s", "sid" ], [ :qualified, "sp", "sid" ] ]
        #           ],
        #           [ :table_as, "parts", "p" ],
        #           [ :eq, [ :qualified, "p", "pid" ], [ :qualified "sp", "pid" ] ]
        #         ],
        #         [ :table_as, "cities", "c" ],
        #       ]
        #     ]
        #
        # Generates a relationally equivalent list of (type,table,predicate)
        # triplets, where:
        #
        # - type is :base, :cross_join, :inner_join, or :left_join
        # - table is table_as, native_table_as or subquery_as
        # - predicate is a join predicate `ti.attri = tj.attrj AND ...`
        #
        # So that
        #
        # 1) the types are observed in strict increasing order (one :base, zero
        #    or more :cross_join, zero or more :inner_join, zero or more :left_join)
        #
        # 2) the list is such that it can be safely written as an expression
        #    of the following SQL syntax:
        #
        #       t1                            # [ :base, t1, nil ]
        #       cross_join t2                 # [ :cross_join, t2, nil ]
        #       cross_join t3                 # [ :cross_join, t3, nil ]
        #       inner_join t4 ON p4           # [ :inner_join, t4, p4 ]
        #       inner_join t5 ON p5           # [ :inner_join, t5, p5 ]
        #       left_join t6 ON p6            # [ :left_join, t6, p6 ]
        #
        #   that is, the linearization is correct only if each predicate `pi`
        #   only makes reference to tables introduced before it (no forward
        #   reference).
        #
        # For the example above, a solution might be:
        #
        #     [
        #       [ :base,       [ :table_as, "suppliers", "s"  ], nil ],
        #       [ :cross_join, [ :table_as, "cities", "c" ],     nil ],
        #       [ :inner_join, [ :table_as, "supplies",  "sp" ],
        #           [ :eq, [ :qualified, "s", "sid" ], [ :qualified, "sp", "sid" ] ] ],
        #       [ :inner_join, [ :table_as, "parts", "p" ],
        #           [ :eq, [ :qualified, "p", "pid" ], [ :qualified "sp", "pid" ] ] ]
        #     ]
        #
        # A NotImplementedError may be raised if no linearization can be found.
        #
        def call(sexpr)
          # The algorithm works in two phases: we first collect all table
          # references and JOIN clauses by simple inspection of the AST.
          tables, joins = collect(sexpr)

          # Then we order the tables and join clauses so as to find the
          # linearization.
          order_all(tables, joins)
        end

      protected  ## Second phase: linearization per se

        # Given a non empty list of tables `ti` and a possibly empty list of
        # join conditions `ti.attri = tj.attrj`, returns a linearization of
        # join triplets meeting the following POST conditions:
        #
        # 1. A triplet is either `[ :base, ti, nil ]`, `[:cross_join, ti, nil]`
        #    or `[ :inner_join, ti, AND([eq]) ]` where `eq` is of the form
        #   `ti.attri = tj.attrj`
        #
        # 2. one and only on `:base` triplet comes first, then `:cross_join`
        #    ones, then `:inner_join` ones.
        #
        # 3. an inner clause at position x in the resulting list is such that
        #    its join conditions `eq` only make reference to tables `ti` that
        #    have been introduced before or in x itself (i.e. no forward
        #    reference to tables not introduced yet)
        #
        def order_all(tables, joins)
          # Our first strategy is simple: let sort the tables by moving the
          # all left joins at the end, and all not referenced in join clauses
          # at the beginning of the list => they will yield the base an cross
          # join clauses first.
          tables = tables.sort{|(t1,k1),(t2,k2)|
            if k1 == :left_join || k2 == :left_join
              k1 == k2 ? 0 : (k1 == :left_join ? 1 : -1)
            else
              t1js = joins.select{|j| uses?(j, t1) }.size
              t2js = joins.select{|j| uses?(j, t2) }.size
              t1js == 0 ? (t2js == 0 ? 0 : -1) : (t2js == 0 ? 1 : 0)
            end
          }

          # Then order all recursively in that order of tables, filling a result
          # array that will be returned
          _order_all(tables, joins, [])
        end

        def _order_all(tables, joins, result)
          if tables.empty? and joins.empty?
            # end or recusion
            result
          elsif tables.empty?
            # Why will this never happen exactly??
            raise NotImplementedError, "Orphan joins: `#{joins.inspect}`"
          else
            # Greedy strategy: we take the first table in the list and keep the
            # rest for recursion later
            table, tables_tail = tables.first, tables[1..-1]

            # Split the remaining joins in two lists: those referencing only
            # introduced tables, and those making forward references
            on, joins_tail = split_joins(joins, table, tables_tail)

            # Decide which kind of join it is, according to the result and
            # the number of join clauses that will be used
            join_kind = if result.empty?
              :base
            elsif table.last == :left_join
              :left_join
            elsif on.empty?
              :cross_join
            else
              :inner_join
            end

            # Compute the AND([eq]) predicate on selected join clauses
            predicate = on.inject(nil){|p,clause|
              p.nil? ? clause : Predicate::Factory.and(p, clause)
            }

            # Recurse with that new clause in the result
            clause = [ join_kind, table[0], predicate ]
            _order_all(tables_tail, joins_tail, result + [clause])
          end
        end

        # Given a list of join `ti.attri = tj.attrj` clauses, a newly introduced
        # ti `table`, and a set of non-yet-introduced tables `tables_tail`,...
        #
        # ... split the joins in two sublists: those making references to table
        # `ti` and making no reference to non introduced tables, and the others.
        def split_joins(joins, table, tables_tail)
          joins.partition{|j|
            uses?(j, table[0]) && !tables_tail.find{|t|
              uses?(j, t[0])
            }
          }
        end

        # Returns whether the join conditions references the given table
        def uses?(condition, table)
          name = table.as_name.to_s
          left_name = var_name(condition[1])
          right_name = var_name(condition[2])
          (left_name == name) or (right_name == name)
        end

        # Given a `ti.attri` expression (AST node), returns `ti`
        def var_name(qualified)
          case qualified.first
          when :qualified_identifier then qualified[1].to_s
          when :qualified_name       then qualified[1][1].to_s
          else
            raise NotImplementedError, "Unexpected qualified name `#{qualified.inspect}`"
          end
        end

      protected ## First phase: collection of tables and join clauses

        # Given a `from_clause` AST (see grammar.sexp.yml), returns two
        # lists:
        # - one with tables `ti` (`table_as`, `native_table_as` & `subquery_as`)
        # - another one with all equality conditions of the form `ti.attri = tj.attrj`
        def collect(sexpr)
          tables = []
          joins  = []
          _collect(sexpr, tables, joins, :base)
          [ tables, joins ]
        end

        def _collect(sexpr, tables, joins, kind)
          case sexpr.first
          when :from_clause
            _collect(sexpr.table_spec, tables, joins, kind)
          when :table_as, :native_table_as, :subquery_as
            tables << [sexpr, kind]
          when :cross_join
            _collect(sexpr.left, tables, joins, :cross_join)
            _collect(sexpr.right, tables, joins, :cross_join)
          when :inner_join
            _collect_joins(sexpr.predicate, joins)
            _collect(sexpr.left, tables, joins, :inner_join)
            _collect(sexpr.right, tables, joins, :inner_join)
          when :left_join
            _collect_joins(sexpr.predicate, joins)
            _collect(sexpr.left, tables, joins, kind)
            _collect(sexpr.right, tables, joins, :left_join)
          end
        end

        def _collect_joins(sexpr, joins)
          case sexpr.first
          when :and
            sexpr[1..-1].each{ |term| _collect_joins(term, joins) }
          when :eq
            joins << sexpr
          else
            raise NotImplementedError, "Unexpected predicate `#{sexpr.inspect}`"
          end
        end

      end # class FromClauseOrderer
    end # module Support
  end # module Sql
end # module Bmg
