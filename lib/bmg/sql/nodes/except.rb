module Bmg
  module Sql
    module Except
      include SetOperator

      EXCEPT = "EXCEPT".freeze

      def keyword
        EXCEPT
      end

    end # module Except
  end # module Sql
end # module Bmg
