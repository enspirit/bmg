module SqlHelpers
  module Ast

    def builder(start = 0)
      @builder ||= Bmg::Sql::Builder.new(start)
    end

    def sexpr(arg)
      Bmg::Sql::Grammar.sexpr(arg)
    end

    def with_exp(spec, selection = select_ab)
      sexpr [:with_exp, with_spec(spec), selection]
    end

    def with_spec(spec = nil)
      spec = {} if spec.nil?
      sexpr spec.map{|k,v|
        [:name_intro, [:table_name, k.to_s], v]
      }.unshift(:with_spec)
    end

    def union(left = select_all, right = select_all_t2)
      sexpr [:union, distinct, left, right]
    end

    def except(left = select_all, right = select_all_t2)
      sexpr [:except, distinct, left, right]
    end

    def intersect(left = select_all, right = select_all_t2)
      sexpr [:intersect, distinct, left, right]
    end

    def nary_intersect(left = intersect, right = select_all_t3)
      raise unless left.first == :intersect
      left + [right]
    end

    def select_is_table_dee(where = nil)
      exists = Predicate::Grammar.sexpr([:exists, where])
      sexpr [:select_exp, all,
              [:select_list,
                [:select_item,
                  [:literal, true],
                  [:column_name, "is_table_dee"]] ],
              [:where_clause, exists] ]
    end

    def select_ab
      sexpr [:select_exp, all, select_list, from_clause]
    end

    def select_a
      sexpr [:select_exp, all, select_list_a, from_clause]
    end

    def select_distinct
      sexpr [:select_exp, distinct, select_list, from_clause]
    end

    def select_distinct_star
      sexpr [:select_exp, distinct, select_star, from_clause]
    end

    def select_distinct_ab
      sexpr [:select_exp, distinct, select_list_ab, from_clause]
    end

    def select_distinct_a
      sexpr [:select_exp, distinct, select_list_a, from_clause]
    end

    def select_all
      sexpr [:select_exp, all, select_list, from_clause]
    end

    def select_all_star_from_native
      sexpr [:select_exp, all, select_star("t1"), from_clause_native("t1")]
    end

    def select_all_star_from_native_as_t2
      sexpr [:select_exp, all, select_star("t2"), from_clause_native("t2")]
    end

    def select_all_star
      sexpr [:select_exp, all, select_star, from_clause]
    end

    def select_all_from_t1_as_t2
      sexpr [:select_exp, all, select_list_t2, from_clause_t1_as_t2]
    end

    def select_all_t2
      sexpr [:select_exp, all, select_list_t2, from_clause_t2]
    end

    def select_all_t3
      sexpr [:select_exp, all, select_list_t3, from_clause_t3]
    end

    def select_all_ab
      sexpr [:select_exp, all, select_list_ab, from_clause]
    end

    def select_all_a
      sexpr [:select_exp, all, select_list_a, from_clause]
    end

    def select_all_a_as_b
      sexpr [:select_exp, all, select_list_a_as_b, from_clause]
    end

    def select_all_b
      sexpr [:select_exp, all, select_list_b, from_clause]
    end

    def select_star(qualifier = builder.next_qualifier!)
      sexpr [:select_star, [:range_var_name, qualifier]]
    end

    def select_list(hash = {"a" => "a", "b" => "b"})
      sexpr [:select_list] + hash.map{|(k,v)| select_item(k, v) }
    end
    alias :select_list_ab :select_list

    def select_list_t2
      sexpr [:select_list, select_item_a_t2, select_item_b_t2 ]
    end

    def select_list_t3
      sexpr [:select_list, select_item_a_t3, select_item_b_t3 ]
    end

    def select_list_ab
      sexpr [:select_list, select_item_a, select_item_b]
    end

    def select_list_ba
      sexpr [:select_list, select_item_b, select_item_a]
    end

    def select_list_a
      sexpr [:select_list, select_item_a]
    end

    def select_list_a_as_b
      sexpr [:select_list, select_item("a","b")]
    end

    def select_list_b
      sexpr [:select_list, select_item_b]
    end

    def select_item_a
      select_item("a")
    end

    def select_item_a_t2
      select_item(qualified_name("t2", "a"), "a")
    end

    def select_item_a_t3
      select_item(qualified_name("t3", "a"), "a")
    end

    def select_item_b_t2
      select_item(qualified_name("t2", "b"), "b")
    end

    def select_item_b_t3
      select_item(qualified_name("t3", "b"), "b")
    end

    def select_item_b
      select_item("b")
    end

    def select_item(name, as = name)
      name = qualified_name("t1", name) unless name.is_a?(Array)
      sexpr [:select_item, name, column_name(as)]
    end

    def column_name_a
      column_name("a")
    end

    def column_name_b
      column_name("b")
    end

    def column_name(x)
      sexpr [:column_name, x]
    end

    def qualified_name_a
      qualified_name("t1", "a")
    end

    def qualified_name_b
      qualified_name("t2", "b")
    end

    def qualified_name(qualifier, name)
      sexpr [:qualified_name, [:range_var_name, qualifier], [:column_name, name]]
    end

    def from_clause
      sexpr [:from_clause, [:table_as, [:table_name, "t1"], [:range_var_name, "t1"]]]
    end

    def from_clause_t2
      sexpr [:from_clause, [:table_as, [:table_name, "t2"], [:range_var_name, "t2"]]]
    end

    def from_clause_t1_as_t2
      sexpr [:from_clause, [:table_as, [:table_name, "t1"], [:range_var_name, "t2"]]]
    end

    def from_clause_t3
      sexpr [:from_clause, [:table_as, [:table_name, "t3"], [:range_var_name, "t3"]]]
    end

    def from_clause_native(as = "t1")
      sexpr [:from_clause, [:native_table_as, "(SELECT * FROM native)", [:range_var_name, as]]]
    end

    def ordering
      [[:a, :asc], [:b, :desc]]
    end

    def subordering
      [[:a, :desc], [:b, :asc]]
    end

    def order_by_clause
      [:order_by_clause,
        order_by_term("a", "asc"),
        order_by_term("b", "desc")]
    end

    def order_by_clause_2
      [:order_by_clause,
        order_by_term("a", "desc"),
        order_by_term("b", "asc")]
    end

    def order_by_term(name, direction)
      name = qualified_name("t1", name) unless name.is_a?(Array)
      sexpr [:order_by_term, name, direction]
    end

    def distinct
      [:set_quantifier, "distinct"]
    end

    def all
      [:set_quantifier, "all"]
    end

  end
  include Ast
end
