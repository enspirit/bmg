module Bmg
  module Sql
    module FuncCall
      include Expr

      def func_name
        self[1]
      end

      def func_args
        self[2..-1]
      end

      def to_sql(buffer, dialect)
        buffer << summary_name.upcase << "("
        buffer << func_args.map{|fa| fa.to_sql("", dialect) }.join(', ')
        buffer << ")"
        buffer
      end

    end # module FuncCall
  end # module Sql
end # module Bmg
