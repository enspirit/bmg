module Bmg
  module Sql
    class Processor
      class Rename < Processor

        def initialize(renaming, builder)
          super(builder)
          @renaming = renaming
        end

        def on_select_list(sexpr)
          sexpr.each_with_index.map{|child,index|
            index == 0 ? child : apply(child)
          }
        end

        def on_select_item(sexpr)
          return sexpr unless newname = @renaming[sexpr.as_name.to_sym]
          builder.select_item(sexpr.qualifier, sexpr.would_be_name, newname.to_s)
        end

      end # class Rename
    end # class Processor
  end # module Sql
end # module Bmg
