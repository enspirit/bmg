module Bmg
  module Sql
    module CaseWhen
      include Expr

      def operand
        self[1]
      end

      def whens
        self[2..-1].each_slice(2).to_a
      end

      def is_computed?
        true
      end

      def to_sql(buffer, dialect)
        buffer << "CASE "
        operand.to_sql(buffer, dialect)
        whens.each do |(when_val, then_val)|
          buffer << " WHEN "
          when_val.to_sql(buffer, dialect)
          buffer << " THEN "
          then_val.to_sql(buffer, dialect)
        end
        buffer << " END"
        buffer
      end

    end # module CaseWhen
  end # module Sql
end # module Bmg
