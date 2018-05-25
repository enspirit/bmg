module Bmg
  module Sql
    class Processor
      class Requalify < Processor

        def initialize(builder)
          super
          @requalify = Hash.new{|h,k|
            h[k] = Grammar.sexpr [:range_var_name, builder.next_qualifier!]
          }
        end
        attr_reader :requalify 

        alias :on_select_exp :copy_and_apply
        alias :on_missing :copy_and_apply

        def on_range_var_name(sexpr)
          requalify[sexpr]
        end

      end # class Requalify
    end # class Processor
  end # module Sql
end # module Bmg
