module Bmg
  module Sql
    module Summarizer
      include Expr

      def summary_func
        self[1]
      end

      def summary_expr
        self.last
      end

      def to_sql(buffer, dialect)
        buffer << summary_func.upcase << "("
        summary_expr.to_sql(buffer, dialect)
        buffer << ")"
        buffer
      end

    end # module Summarizer
  end # module Sql
end # module Bmg
