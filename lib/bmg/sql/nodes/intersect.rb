module Bmg
  module Sql
    module Intersect
      include SetOperator

      INTERSECT = "INTERSECT".freeze

      def keyword
        INTERSECT
      end

    end # module Intersect
  end # module Sql
end # module Bmg
