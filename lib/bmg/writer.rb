module Bmg
  module Writer

  protected

    def infer_headers(from)
      attrlist = if from.is_a?(Type) && from.knows_attrlist?
        from.to_attrlist
      elsif from.is_a?(Hash)
        from.keys
      end
      attrlist ? output_preferences.order_attrlist(attrlist) : nil
    end

    def each_tuple(relation, &bl)
      if ordering = output_preferences.tuple_ordering
        relation
          .to_a
          .sort{|t1,t2| ordering.compare_attrs(t1, t2) }
          .each_with_index(&bl)
      else
        relation.each_with_index(&bl)
      end
    end

  end # module Writer
end # module Bmg
require_relative 'writer/csv'
