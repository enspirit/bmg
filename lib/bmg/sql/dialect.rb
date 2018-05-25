module Bmg
  module Sql
    class Dialect

      def self.default
        Dialect.new
      end

      def quote_identifier(identifier)
        %Q{"#{identifier}"}
      end

    end # class Dialect
  end # module Sql
end # module Bmg