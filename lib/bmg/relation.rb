module Bmg
  module Relation
    include Enumerable
    include Algebra

    def self.new(operand, type = Type::ANY)
      raise ArgumentError, "Missing type" if type.nil?
      operand.is_a?(Relation) ? operand : Bmg.in_memory(operand, type)
    end

    def self.empty(type = Type::ANY)
      raise ArgumentError, "Missing type" if type.nil?
      Relation::Empty.new(type)
    end

    def bind(binding)
      self
    end

    def type
      Bmg::Type::ANY
    end

    def with_type(type)
      dup.tap{|r|
        r.type = type
      }
    end

    def with_typecheck
      dup.tap{|r|
        r.type = r.type.with_typecheck
      }
    end

    def without_typecheck
      dup.tap{|r|
        r.type = r.type.with_typecheck
      }
    end

    def empty?
      each{|t| return false }
      true
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

    def insert(arg)
      raise InvalidUpdateError, "Cannot insert into this Relvar"
    end

    def update(arg)
      raise InvalidUpdateError, "Cannot update this Relvar"
    end

    def delete
      raise InvalidUpdateError, "Cannot delete from this Relvar"
    end

    def visit(&visitor)
      _visit(nil, visitor)
    end

    def _visit(parent, visitor)
      visitor.call(self, parent)
    end
    protected :_visit

    def y_by_x(y, x, options = {})
      each_with_object({}) do |tuple, h|
        h[tuple[x]] = tuple[y]
      end
    end

    def ys_by_x(y, x, options = {})
      ordering = options[:order]
      projection = [y, ordering].compact.uniq
      by_x = each_with_object({}) do |tuple,h|
        h[tuple[x]] ||= []
        h[tuple[x]] << TupleAlgebra.project(tuple, projection)
      end
      by_x.each_with_object({}) do |(x,ys),h|
        ys = ys.sort{|y1,y2| y1[ordering] <=> y2[ordering] } if ordering
        ys = ys.map{|t| t[y] }
        ys = ys.uniq if options[:distinct]
        h[x] = ys
      end
    end

    def count
      if type.knows_keys?
        project(type.keys.first)._count
      else
        self._count
      end
    end

    def _count
      to_a.size
    end

    # Returns a json representation
    def to_json(*args, &bl)
      to_a.to_json(*args, &bl)
    end

    # Writes the relation data to CSV.
    #
    # `string_or_io` and `options` are what CSV::new itself
    # recognizes, default options are CSV's.
    #
    # When no string_or_io is used, the method uses a string.
    #
    # The method always returns the string_or_io.
    def to_csv(options = {}, string_or_io = nil, preferences = nil)
      options, string_or_io = {}, options unless options.is_a?(Hash)
      string_or_io, preferences = nil, string_or_io if string_or_io.is_a?(Hash)
      Writer::Csv.new(options, preferences).call(self, string_or_io)
    end

    # Converts to an sexpr expression.
    def to_ast
      raise "Bmg is missing a feature!"
    end

    # Returns a String representing the query plan
    def debug(max_level = nil, on = STDERR)
      on.puts(self.inspect)
      self
    end

  end # module Relation
end # module Bmg
