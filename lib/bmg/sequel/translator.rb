module Bmg
  module Sequel
    class Translator < Sexpr::Processor
      include ::Predicate::ToSequel::Methods

      def initialize(sequel_db)
        @sequel_db = sequel_db
      end
      attr_reader :sequel_db

      def on_with_exp(sexpr)
        if sequel_db.select(1).supports_cte?
          dataset = apply(sexpr.select_exp)
          apply(sexpr.with_spec).each_pair do |name,subquery|
            dataset = dataset.with(name, subquery)
          end
          dataset
        else
          apply(Sql::Processor::Flatten.new(Sql::Builder.new).call(sexpr))
        end
      end

      def on_with_spec(sexpr)
        sexpr.each_with_object({}){|child,hash|
          next if child == :with_spec
          hash[apply(child.table_name)] = apply(child.subquery)
        }
      end

      def on_set_operator(sexpr)
        sexpr.tail_exprs.inject(apply(sexpr.head_expr)) do |left,right|
          left.send(sexpr.first, apply(right), all: sexpr.all?, from_self: false)
        end
      end
      alias :on_union     :on_set_operator
      alias :on_intersect :on_set_operator
      alias :on_except    :on_set_operator

      def on_select_exp(sexpr)
        dataset   = sequel_db.select(1)
        dataset   = dataset(apply(sexpr.from_clause)) if sexpr.from_clause
        #
        selection = apply(sexpr.select_list)
        predicate = apply(sexpr.predicate)       if sexpr.predicate
        order     = apply(sexpr.order_by_clause) if sexpr.order_by_clause
        limit     = apply(sexpr.limit_clause)    if sexpr.limit_clause
        offset    = apply(sexpr.offset_clause)   if sexpr.offset_clause
        #
        dataset   = dataset.select(*selection)
        dataset   = dataset.distinct             if sexpr.distinct?
        dataset   = dataset.where(predicate)     if predicate
        dataset   = dataset.order_by(*order)     if order
        dataset   = dataset.limit(limit, offset == 0 ? nil : offset) if limit or offset
        dataset
      end

      def on_select_list(sexpr)
        sexpr.sexpr_body.map{|c| apply(c) }
      end

      def on_select_star(sexpr)
        ::Sequel.lit('*')
      end

      def on_select_item(sexpr)
        left  = apply(sexpr.left)
        right = apply(sexpr.right)
        case kind = sexpr.left.first
        when :qualified_name
          left.column == right.value ? left : ::Sequel.as(left, right)
        when :literal
          ::Sequel.as(left, right)
        else
          raise NotImplementedError, "Unexpected select item `#{kind}`"
        end
      end

      def on_qualified_name(sexpr)
        apply(sexpr.last).qualify(sexpr.qualifier)
      end

      def on_column_name(sexpr)
        ::Sequel.expr(sexpr.last.to_sym)
      end

      def on_from_clause(sexpr)
        apply(sexpr.table_spec)
      end

      def on_table_name(sexpr)
        ::Sequel.expr(sexpr.last.to_sym)
      end

      def on_cross_join(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        dataset(left).cross_join(right)
      end

      def on_inner_join(sexpr)
        left, right = apply(sexpr.left), apply(sexpr.right)
        options = {qualify: false, table_alias: false}
        dataset(left).join_table(:inner, right, nil, options){|*args|
          apply(sexpr.predicate)
        }
      end

      def on_table_as(sexpr)
        ::Sequel.as(::Sequel.expr(sexpr.table_name.to_sym), ::Sequel.identifier(sexpr.as_name))
      end

      def on_subquery_as(sexpr)
        ::Sequel.as(apply(sexpr.subquery), ::Sequel.identifier(sexpr.as_name))
      end

      def on_native_table_as(sexpr)
        sexpr[1].from_self(:alias => sexpr.as_name)
      end

      def on_order_by_clause(sexpr)
        sexpr.sexpr_body.map{|c| apply(c)}
      end

      def on_order_by_term(sexpr)
        ::Sequel.send(sexpr.direction, apply(sexpr.qualified_name))
      end

      def on_limit_clause(sexpr)
        sexpr.last
      end

      def on_offset_clause(sexpr)
        sexpr.last
      end

    public ### Predicate hack

      def on_in(sexpr)
        left, right = apply(sexpr.identifier), sexpr.last
        right = apply(right) if sexpr.subquery?
        ::Sequel.expr(left => right)
      end

      def on_exists(sexpr)
        apply(sexpr.last).exists
      end

    private

      def dataset(expr)
        return expr if ::Sequel::Dataset===expr
        sequel_db[expr]
      end

    end # class Translator
  end # module Sequel
end # module Bmg
