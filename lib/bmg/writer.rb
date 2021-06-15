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

    def infer_formats(relation, headers)
      relation
        .page([], 1, page_size: 100)
        .summarize([], headers.each_with_object({}){|h,memo|
          memo[h] = Summarizer.multiple({
            :count => Summarizer.count,
            :min => Summarizer.min(h.to_sym),
            :max => Summarizer.max(h.to_sym),
            :distinct => Summarizer.distinct(h.to_sym),
            :types => Summarizer.by_proc{|t,memo| ((memo || []) << t[h.to_sym].class).uniq },
            :length_80 => Summarizer.percentile(80){|t| t[h.to_sym].to_s.size }
          })
          memo
        })
        .tap{|r| puts JSON.pretty_generate(r.one) }
    end

  end # module Writer
end # module Bmg
require_relative 'writer/csv'
