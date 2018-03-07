module Bmg
  module Relation
    include Enumerable
    include Algebra

    def self.new(operand, type = Type::ANY)
      operand.is_a?(Relation) ? operand : Leaf.new(type, operand)
    end

    def self.empty(type = Type::ANY)
      Relation.new([])
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

    # Converts to an sexpr expression.
    def to_ast
      raise "Bmg is missing a feature!"
    end

    # Returns a String representing the query plan
    def debug(max_level = nil, on = STDERR)
      on.puts _debug(to_ast, 1, max_level)
      self
    end

  private

    def _debug(ast, level = 1, max_level = nil)
      return ast.inspect if ast.is_a?(Symbol)
      return ast.to_s unless ast.is_a?(Array)
      return ast.to_s unless ast.first.is_a?(Symbol)
      if max_level && level>max_level
        "(#{ast.first} ...)"
      else
        sep = "  " * level
        "(#{ast.first}\n" + ast[1..-1].map{|a| _debug(a, 1+level, max_level) }.join("\n").gsub(/^/, sep) + ")"
      end
    end

  end # module Relation
end # module Bmg
