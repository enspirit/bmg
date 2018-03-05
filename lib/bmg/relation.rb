module Bmg
  module Relation
    include Enumerable
    include Algebra

    def self.new(operand, type = Type::ANY)
      operand.is_a?(Relation) ? operand : Leaf.new(type, operand)
    end

    # Private helper to implement `one` and `one_or_nil`
    def one_or_yield(&bl)
      first = nil
      each do |x|
        raise OneError, "Relation has more than one tuple" unless first.nil?
        first = x
      end
      first.nil? ? bl.call : first
    end
    private :one_or_yield

    # Returns the only tuple that the relation contains.
    # Throws a OneException when there is no tuple or more than one
    def one
      one_or_yield{ raise OneError, "Relation is empty" }
    end

    # Returns the only tuple that the relation contains.
    # Returns nil if the relation is empty.
    # Throws a OneException when the relation contains more than one tuple
    def one_or_nil
      one_or_yield{ nil }
    end

  end # module Relation
end # module Bmg
