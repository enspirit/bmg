module Bmg
  class OutputPreferences

    DEFAULT_PREFS = {
      attributes_ordering: nil,
      tuple_ordering: nil,
      grouping_attributes: nil,
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

    def tuple_ordering
      return nil unless to = options[:tuple_ordering]

      @tuple_ordering = Ordering.new(to)
    end

    def attributes_ordering
      options[:attributes_ordering]
    end

    def extra_attributes
      options[:extra_attributes]
    end

    def grouping_attributes
      options[:grouping_attributes]
    end

    def grouping_character
      options[:grouping_character]
    end

    def erase_redundance_in_group(before, current)
      return [nil, current] unless ga = grouping_attributes
      return [current, current] unless before

      new_before, new_current = current.dup, current.dup
      ga.each do |attr|
        unless before[attr] == current[attr]
          return [new_before, new_current]
        end
        new_current[attr] = grouping_character
      end
      [new_before, new_current]
    end

    def order_attrlist(attrlist)
      return attrlist if attributes_ordering.nil?

      index = Hash[attributes_ordering.each_with_index.to_a]
      base  = attrlist
      base  = attrlist & attributes_ordering if extra_attributes == :ignored
      base.sort{|a,b|
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
