module Bmg
  module TupleAlgebra

    def allbut(tuple, butlist)
      tuple.reject{|k,v| butlist.include?(k) }
    end
    module_function :allbut

    def project(tuple, attrlist)
      tuple.reject{|k,v| !attrlist.include?(k) }
    end
    module_function :project

    def rename(tuple, renaming)
      tuple.each_with_object({}){|(k,v),m|
        m[renaming[k] || k] = v
        m
      }
    end
    module_function :rename

  end # module TupleAlgebra
end # module Bmg
