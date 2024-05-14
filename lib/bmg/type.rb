module Bmg
  class Type

    def initialize(predicate = Predicate.tautology)
      @predicate = predicate
      @typechecked = false
      raise ArgumentError if @predicate.nil?
    end

    ANY = Type.new

  public ## type checking

    attr_writer :typechecked
    protected :typechecked=

    def typechecked?
      @typechecked
    end

    def with_typecheck
      dup.tap{|x|
        x.typechecked = true
      }
    end

    def without_typecheck
      dup.tap{|x|
        x.typechecked = false
      }
    end

  public ## predicate

    attr_accessor :predicate
    protected :predicate=

    def with_predicate(predicate)
      dup.tap{|x|
        x.predicate = predicate
      }
    end

  public ## attrlist

    attr_accessor :attrlist
    protected :attrlist=

    def attrlist!
      knows_attrlist!
      attrlist
    end

    def with_attrlist(attrlist)
      dup.tap{|x|
        x.attrlist = attrlist
      }
    end

    def knows_attrlist?
      !self.attrlist.nil?
    end

    def knows_attrlist!
      raise UnknownAttributesError unless knows_attrlist?
    end

    def to_attrlist
      self.attrlist
    end

  public ## keys

    attr_accessor :keys
    alias :_keys :keys
    protected :_keys, :keys=

    def knows_keys?
      !!@keys
    end

    def keys
      return @keys.to_a if @keys
      return [attrlist] if knows_attrlist?
      nil
    end

    def with_keys(keys)
      dup.tap{|x|
        x.keys = keys ? Keys.new(keys) : nil
      }
    end

  public ## typing

    def [](attribute)
      ANY
    end

  public ### algebra

    def allbut(butlist)
      known_attributes!(butlist) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = self.attrlist - butlist if knows_attrlist?
        x.predicate = Predicate.tautology
        x.keys      = self._keys.allbut(self, x, butlist) if knows_keys?
      }
    end

    def identity_autowrap?(options)
      return false unless knows_attrlist?

      sep = Operator::Autowrap.separator(options)
      self.attrlist.all?{|a| a.to_s.index(sep).nil? }
    end

    def autowrap(options)
      sep = Operator::Autowrap.separator(options)
      splitter = ->(a){ a.to_s.split(sep).first }
      is_split = ->(a){ a.to_s.split(sep).size > 1 }
      dup.tap{|x|
        x.attrlist  = self.attrlist.map(&splitter).uniq.map(&:to_sym) if knows_attrlist?
        x.keys      = self._keys.autowrap(self, x, options) if knows_keys?
        autowrapped = self.predicate.free_variables.select(&is_split)
        x.predicate = autowrapped.empty? ? self.predicate : self.predicate.and_split(autowrapped).last
      }
    end

    def autosummarize(by, summarization, options)
      known_attributes!(by + summarization.keys) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist = nil
        x.predicate = Predicate.tautology
        x.keys = nil
      }
    end

    def constants(cs)
      unknown_attributes!(cs.keys) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = self.attrlist + cs.keys if knows_attrlist?
        x.predicate = self.predicate & Predicate.eq(cs)
        ### keys stay the same
      }
    end

    def extend(extension)
      unknown_attributes!(extension.keys) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = self.attrlist + extension.keys if knows_attrlist?
        x.predicate = Predicate.tautology
        ### keys stay the same (?)
      }
    end

    def group(attrs, as)
      if typechecked? && knows_attrlist?
        known_attributes!(attrs)
        unknown_attributes!([as])
      end
      dup.tap{|x|
        x.attrlist  = self.attrlist - attrs + [as] if knows_attrlist?
        x.predicate = Predicate.tautology
        x.keys      = self._keys.group(self, x, attrs, as) if knows_keys?
      }
    end

    def image(right, as, on, options)
      if typechecked? && knows_attrlist?
        join_compatible!(right, on)
        unknown_attributes!([as])
      end
      dup.tap{|x|
        x.attrlist  = self.attrlist + [as] if knows_attrlist?
        x.predicate = Predicate.tautology
        x.keys      = self._keys
      }
    end

    def join(right, on)
      join_compatible!(right, on) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = (knows_attrlist? and right.knows_attrlist?) ? (self.attrlist + right.attrlist).uniq : nil
        x.predicate = self.predicate & right.predicate
        x.keys      = (knows_keys? and right.knows_keys?) ? self._keys.join(self, x, right, on) : nil
      }
    end

    def left_join(right, on, default_right_tuple)
      join_compatible!(right, on) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = (knows_attrlist? and right.knows_attrlist?) ? (self.attrlist + right.attrlist).uniq : nil
        x.predicate = Predicate.tautology
        x.keys      = nil
      }
    end

    def matching(right, on)
      join_compatible!(right, on) if typechecked? && knows_attrlist?
      self
    end

    def not_matching(right, on)
      join_compatible!(right, on) if typechecked? && knows_attrlist?
      self
    end

    def page(ordering, page_size, options)
      known_attributes!(ordering.map{|(k,v)| k}) if typechecked? && knows_attrlist?
      self
    end

    def project(attrlist)
      known_attributes!(attrlist) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = attrlist
        x.predicate = Predicate.tautology
        x.keys      = self._keys.project(self, x, attrlist) if knows_keys?
      }
    end

    def rename(renaming)
      if typechecked? && knows_attrlist?
        known_attributes!(renaming.keys)
        unknown_attributes!(renaming.values)
      end
      new_pred = begin
        self.predicate.rename(renaming)
      rescue Predicate::NotSupportedError => e
        Predicate.tautology
      end
      dup.tap{|x|
        x.attrlist  = self.attrlist.map{|a| renaming[a] || a } if knows_attrlist?
        x.predicate = new_pred
        x.keys      = self._keys.rename(self, x, renaming) if knows_keys?
      }
    end

    def restrict(predicate)
      known_attributes!(predicate.free_variables) if typechecked? && knows_attrlist?
      dup.tap{|x|
        ### attrlist stays the same
        x.predicate = self.predicate & predicate
        x.keys      = self._keys.restrict(self, x, predicate) if knows_keys?
      }
    end

    def summarize(by, summarization)
      dup.tap{|x|
        x.attrlist = by + summarization.keys
        x.keys     = Keys.new([by])
      }
    end

    def transform(transformation, options = {})
      transformer = TupleTransformer.new(transformation)
      if typechecked? && knows_attrlist? && transformer.knows_attrlist?
        known_attributes!(transformer.to_attrlist)
      end
      keys = if options[:key_preserving]
        self._keys
      elsif transformer.knows_attrlist? && knows_keys?
        touched_attrs = transformer.to_attrlist
        keys = self._keys.select{|k| (k & touched_attrs).empty? }
      else
        nil
      end
      pred = if transformer.knows_attrlist?
        attr_list = transformer.to_attrlist
        predicate.and_split(attr_list).last
      else
        Predicate.tautology
      end
      dup.tap{|x|
        x.keys = keys
        x.predicate = pred
      }
    end

    def ungroup(attrlist)
      known_attributes!(attrlist) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = nil
        x.predicate = Predicate.tautology
        x.keys      = nil
      }
    end

    def check_union_compatible(other, opname)
      if typechecked? && knows_attrlist? && other.knows_attrlist?
        missing = self.attrlist - other.attrlist
        raise TypeError, "#{opname} requires compatible attribute lists, but the right operand is missing the following attributes: #{missing.join(', ')}" unless missing.empty?
        extra = other.attrlist - self.attrlist
        raise TypeError, "#{opname} requires compatible attribute lists, but the left operand is missing the following attributes: #{extra.join(', ')}" unless extra.empty?
      end
    end

    def union(other)
      check_union_compatible(other, "Union")
      dup.tap{|x|
        ### attrlist stays the same
        x.predicate = self.predicate | predicate
        x.keys      = self._keys.union(self, x, other) if knows_keys?
      }
    end

    def minus(other)
      check_union_compatible(other, "Minus")
      dup.tap{|x|
        ### attrlist stays the same
        x.predicate = self.predicate & predicate
        x.keys      = self._keys.union(self, x, other) if knows_keys?
      }
    end

    def unwrap(attrlist)
      known_attributes!(attrlist) if typechecked? && knows_attrlist?
      dup.tap{|x|
        x.attrlist  = nil
        x.predicate = predicate.and_split(attrlist).last
        x.keys      = self._keys.unwrap(self, x, attrlist) if knows_keys?
      }
    end

  public

    def known_attributes!(attrs)
      extra = attrs - self.attrlist
      raise TypeError, "Unknown attributes #{extra.join(', ')}" unless extra.empty?
    end

    def unknown_attributes!(attrs)
      clash = self.attrlist & attrs
      raise TypeError, "Existing attributes #{clash.join(', ')}" unless clash.empty?
    end

    def join_compatible!(right, on)
      extra = on - self.attrlist
      raise TypeError, "Unknow attributes #{extra.join(', ')}" unless extra.empty?
      if right.knows_attrlist?
        extra = on - right.attrlist
        raise TypeError, "Unknow attributes #{extra.join(', ')}" unless extra.empty?
      end
    end

    def cross_join_compatible!(right)
      shared = self.attrlist & right.type.attrlist
      unless shared.empty?
        raise TypeError, "Cross product incompatible — duplicate attribute(s): #{shared.join(', ')}"
      end
    end

  end # class Type
end # module Bmg
