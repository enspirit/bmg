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

    def symbolize_keys(h)
      return h if h.empty?
      h.each_with_object({}){|(k,v),h| h[k.to_sym] = v }
    end
    module_function :symbolize_keys

  end # module TupleAlgebra
end # module Bmg
