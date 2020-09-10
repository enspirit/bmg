module Bmg
  class OutputPreferences

    DEFAULT_PREFS = {
      attributes_ordering: nil,
      extra_attributes: :after
    }

    def initialize(options)
      @options = DEFAULT_PREFS.merge(options)
    end
    attr_reader :options

    def self.dress(arg)
      return arg if arg.is_a?(OutputPreferences)
      arg = {} if arg.nil?
      new(arg)
    end

    def attributes_ordering
      options[:attributes_ordering]
    end

    def extra_attributes
      options[:extra_attributes]
    end

    def order_attrlist(attrlist)
      return attrlist if attributes_ordering.nil?
      index = Hash[attributes_ordering.each_with_index.to_a]
      attrlist.sort{|a,b|
        ai, bi = index[a], index[b]
        if ai && bi
          ai <=> bi
        elsif ai
          extra_attributes == :after ? -1 : 1
        else
          extra_attributes == :after ? 1 : -1
        end
      }
    end

  end # class OutputPreferences
end # module Bmg
