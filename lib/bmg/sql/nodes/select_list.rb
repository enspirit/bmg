module Bmg
  module Sql
    module SelectList
      include Expr

      def desaliaser(for_predicate = false)
        ->(a){
          item = sexpr_body.find{|item| item.as_name.to_s == a.to_s }
          return nil unless left = item && item.left
          return left unless for_predicate
          case left.first
          when :literal
            Predicate::Grammar.sexpr([:literal, left.last])
          when :qualified_name
            Predicate::Grammar.sexpr([:qualified_identifier, left.qualifier.to_sym, left.as_name.to_sym])
          else
            raise "Unexpected select_item `#{left}`"
          end
        }
      end

      def is_table_dee?
        Builder::IS_TABLE_DEE == self
      end

      def has_computed_attributes?
        sexpr_body.any?{|item| item.is_computed? }
      end

      def knows?(as_name)
        find_child{|child| child.as_name == as_name }
      end

      def to_attr_list
        sexpr_body.map{|a| a.as_name.to_sym }
      end

      def to_sql(buffer, dialect)
        sexpr_body.each_with_index do |item,index|
          buffer << COMMA << SPACE unless index == 0
          item.to_sql(buffer, dialect)
        end
        buffer
      end

    end # module SelectList
  end # module Sql
end # module Bmg
