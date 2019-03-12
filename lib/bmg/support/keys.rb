module Bmg
  class Keys

    def initialize(keys, reduce = false)
      @keys = reduce ? reduce(keys) : keys
    end

  public ## tools

  public ## algebra

    def allbut(oldtype, newtype, butlist)
      keys = @keys.select{|k| (k & butlist).empty? }
      keys = [newtype.attrlist] if keys.empty?
      Keys.new(keys, false)
    end

    def autowrap(oldtype, newtype, options)
      sep = options[:split] || Operator::Autowrap::DEFAULT_OPTIONS[:split]
      keys = @keys.map{|k|
        k.map{|a| a.to_s.split(sep).first }.uniq.map(&:to_sym)
      }
      Keys.new(keys, false)
    end

    def group(oldtype, newtype, attrs, as)
      keys = [ oldtype.attrlist - attrs ]
      keys += @keys.map{|k| (k & attrs).empty? ? k : (k - attrs) + [as] }
      Keys.new(keys, true)
    end

    def join(oldtype, newtype, right_type, on)
      return nil  unless rkeys = right_type.keys
      return self if rkeys.any?{|k| (k - on).empty? }
      keys = []
      @keys.each do |k1|
        right_type.keys.each do |k2|
          keys << (k1 + k2).uniq
        end
      end
      Keys.new(keys, true)
    end

    def project(oldtype, newtype, attrlist)
      keys = @keys.select{|k| k.all?{|a| attrlist.include?(a) } }
      keys = [newtype.attrlist] if keys.empty?
      Keys.new(keys, false)
    end

    def rename(oldtype, newtype, renaming)
      keys = @keys.map{|k| k.map{|a| renaming[a] || a } }
      Keys.new(keys, false)
    end

    def restrict(oldtype, newtype, predicate)
      return self if (cs = predicate.constant_variables).empty?
      keys = @keys.map{|k| k - cs }
      Keys.new(keys, false)
    end

    def union(oldtype, newtype, right_type)
      return nil unless rkeys = right_type.keys
      return nil unless (oldtype.predicate & right_type.predicate).contradiction?
      shared = @keys.select{|k| rkeys.include?(k) }
      Keys.new(shared, false)
    end

  public ## usuals

    def to_a
      @keys
    end

  private

    def reduce(keys)
      reduced = []
      keys.sort{|a,b| a.size <=> b.size}.each do |k|
        reduced << k unless reduced.any?{|r| (r - k).empty? }
      end
      reduced
    end

  end
end
