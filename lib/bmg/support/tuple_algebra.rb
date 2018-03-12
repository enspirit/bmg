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

  end # module TupleAlgebra
end # module Bmg
