module Bmg
  module Sql
    module LeftJoin
      include Expr
      include Join

      LEFT = "LEFT".freeze

      def type
        LEFT
      end

    end # module LeftJoin
  end # module Sql
end # module Bmg
