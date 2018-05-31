module Bmg
  module Sql
    module SelectStar
      include Expr

      STAR = "*".freeze

      def desaliaser(*args, &bl)
        ->(a){
          Predicate::Grammar.sexpr [ :qualified_identifier, last[1], a.to_s ]
        }
      end

      def to_sql(buffer, dialect)
        last.to_sql(buffer, dialect)
        buffer << DOT << STAR
        buffer
      end

    end # module SelectStar
  end # module Sql
end # module Bmg
