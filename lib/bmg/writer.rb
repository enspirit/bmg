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

  end # module Writer
end # module Bmg
require_relative 'writer/csv'
