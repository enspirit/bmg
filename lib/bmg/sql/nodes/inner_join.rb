module Bmg
  module Sql
    module InnerJoin
      include Expr

      INNER = "INNER".freeze
      JOIN  = "JOIN".freeze
      ON    = "ON".freeze

      def join?
        true
      end

      def left
        self[1]
      end

      def right
        self[2]
      end

      def predicate
        last
      end

      def to_sql(buffer, dialect)
        left.to_sql(buffer, dialect)
        buffer << SPACE << JOIN << SPACE
        right.to_sql(buffer, dialect)
        buffer << SPACE << ON << SPACE
        predicate.to_sql(buffer, dialect)
        buffer
      end

    end # module InnerJoin
  end # module Sql
end # module Bmg
