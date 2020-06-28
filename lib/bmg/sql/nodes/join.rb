module Bmg
  module Sql
    module Join
      include Expr

      JOIN  = "JOIN".freeze
      ON    = "ON".freeze

      def type
        nil
      end

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
        if type.nil?
          buffer << SPACE << JOIN << SPACE
        else
          buffer << SPACE << TYPE << SPACE << JOIN << SPACE
        end
        right.to_sql(buffer, dialect)
        buffer << SPACE << ON << SPACE
        predicate.to_sql(buffer, dialect)
        buffer
      end

    end # module Join
  end # module Sql
end # module Bmg
