module Bmg
  module Sql
    module Union
      include SetOperator

      UNION = "UNION".freeze

      def keyword
        UNION
      end

    end # module Union
  end # module Sql
end # module Bmg
