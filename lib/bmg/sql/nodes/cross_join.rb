module Bmg
  module Sql
    module CrossJoin
      include Expr

      def join?
        true
      end

      def left
        self[1]
      end

      def right
        self[2]
      end

      def to_sql(buffer, dialect)
        each_child do |child, index|
          buffer << COMMA << SPACE unless index == 0
          child.to_sql(buffer, dialect)
        end
        buffer
      end

    end # module CrossJoin
  end # module Sql
end # module Bmg
