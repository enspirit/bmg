module Bmg
  module Sql
    module SetQuantifier
      include Expr

      def all?
        last == "all"
      end

      def distinct?
        last == "distinct"
      end

      def to_sql(buffer, dialect)
        buffer << self.last
      end

    end # module SetQuantifier
  end # module Sql
end # module Bmg
