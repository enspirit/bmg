module Bmg
  module Sql
    class Processor < Sexpr::Rewriter
      grammar Sql::Grammar

      UnexpectedError = Class.new(Bmg::Error)

      def initialize(builder)
        @builder = builder
      end
      attr_reader :builder

      def on_with_exp(sexpr)
        applied = apply(sexpr.select_exp)
        if applied.with_exp?
          merge_with_exps(sexpr, applied, applied.select_exp)
        else
          sexpr.with_update(-1, applied)
        end
      end

      def on_set_operator(sexpr)
        sexpr.each_with_index.map{|child,index|
          index <= 1 ? child : apply(child)
        }
      end
      alias :on_union     :on_set_operator
      alias :on_except    :on_set_operator
      alias :on_intersect :on_set_operator

      def on_select_exp(sexpr)
        sexpr.with_update(2, apply(sexpr[2]))
      end

    private

      def merge_with_exps(left, right, main)
        if left.with_exp? and right.with_exp?
          [ :with_exp,
            merge_with_specs(left.with_spec, right.with_spec),
            main ]
        elsif left.with_exp?
          left.with_update(-1, main)
        elsif right.with_exp?
          right.with_update(-1, main)
        else
          main
        end
      end

      def merge_with_specs(left, right)
        hash = left.to_hash.merge(right.to_hash){|k,v1,v2|
          unless v1 == v2
            msg = "Unexpected different SQL expr: "
            msg << "`#{v1.inspect}` vs. `#{v2.inspect}`"
            raise UnexpectedError, msg
          end
          v1
        }
        hash.map{|(k,v)| builder.name_intro(k,v) }.unshift(:with_spec)
      end

      def tautology
        Predicate::Factory.tautology
      end

    end
  end
end
require_relative 'processor/distinct'
require_relative 'processor/all'
require_relative 'processor/clip'
require_relative 'processor/star'
require_relative 'processor/rename'
require_relative 'processor/order_by'
require_relative 'processor/limit_offset'
require_relative 'processor/from_self'
require_relative 'processor/reorder'
require_relative 'processor/merge'
require_relative 'processor/where'
require_relative 'processor/join_support'
require_relative 'processor/join'
require_relative 'processor/semi_join'
require_relative 'processor/flatten'
require_relative 'processor/requalify'
