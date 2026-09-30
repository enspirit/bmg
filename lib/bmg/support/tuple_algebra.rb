module Bmg
  #
  # Tuple-level counterparts of the relational operators.
  #
  module TupleAlgebra

    # `allbut` and `project` below test every attribute of every tuple for
    # membership in an attribute list, so the cost of that lookup is paid
    # `tuples x attributes` times. Converting the list to a Set is worth it,
    # but only past a few elements: below that an Array scan wins, on every
    # ruby (measured in bench/set_vs_array.rb). Join keys, in particular,
    # are usually one or two attributes and are better left alone.
    #
    # Callers that iterate are expected to hoist this out of their loop.
    SET_FROM = 3

    def membership(attrlist)
      attrlist.size < SET_FROM ? attrlist : attrlist.to_set
    end
    module_function :membership

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
