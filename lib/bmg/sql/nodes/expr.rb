module Bmg
  module Sql
    module Expr

      LEFT_PARENTHESE  = "(".freeze
      RIGHT_PARENTHESE = ")".freeze
      SPACE            = " ".freeze
      COMMA            = ",".freeze
      DOT              = ".".freeze
      QUOTE            = "'".freeze
      AS               = "AS".freeze
      AND              = "AND".freeze
      OR               = "OR".freeze
      NOT              = "NOT".freeze
      TRUE             = "TRUE".freeze
      FALSE            = "FALSE".freeze
      EQUAL            = "=".freeze
      NOT_EQUAL        = "<>".freeze
      GREATER          = ">".freeze
      LESS             = "<".freeze
      GREATER_OR_EQUAL = ">=".freeze
      LESS_OR_EQUAL    = "<=".freeze
      IN               = "IN".freeze
      EXISTS           = "EXISTS".freeze

      def set_operator?
        false
      end

      def limit_or_offset?
        not(limit_clause.nil? and offset_clause.nil?)
      end

      def join?
        false
      end

      def ordering
        obc = order_by_clause
        obc && order_by_clause.to_ordering
      end

      def with_update(index, what)
        index = find_child_index(index) if index.is_a?(Symbol)
        dup.tap{|x| x[index] = Grammar.sexpr(what) }
      end

      def with_insert(index, what)
        dup.tap{|x| x.insert(index, Grammar.sexpr(what)) }
      end

      def with_push(*sexprs)
        dup.push(*sexprs)
      end

      def each_child(skip = 0)
        each_with_index do |c,i|
          next if i <= skip
          yield(c, i - 1)
        end
      end

      def flatten
        Processor::Flatten.new(nil).call(self)
      end

    private

      def find_child(kind = nil, &search)
        if search.nil? and kind
          search = ->(x){ x.is_a?(Array) && x.first == kind }
        end
        each_child do |child|
          return child if search.call(child)
        end
        nil
      end

      def find_child_index(kind)
        each_with_index do |child,index|
          return index if child.is_a?(Array) && child.first == kind
        end
        nil
      end

      def sql_parenthesized(buffer)
        buffer << LEFT_PARENTHESE
        yield(buffer)
        buffer << RIGHT_PARENTHESE
      end

    end # module Expr
  end # module Sql
end # module Bmg
