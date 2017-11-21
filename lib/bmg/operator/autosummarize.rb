module Bmg
  module Operator
    #
    # Autosummarize operator.
    #
    # Autosummarize helps structuring the results of a big flat join.
    #
    # This operator is still largely experimental and should be used with
    # care...
    #
    class Autosummarize
      include Operator

      def initialize(operand, by, sums)
        @operand = operand
        @by = by
        @sums = sums.each_with_object({}){|(k,v),h| h[k] = to_summarizer(v) }
      end

      def each(&bl)
        h = {}
        @operand.each do |tuple|
          key = key(tuple)
          h[key] ||= init(key, tuple)
          h[key] = sum(h[key], tuple)
        end
        h.each_pair do |k,v|
          h[k] = term(v)
        end
        h.values.each(&bl)
      end

    private

      # Returns the tuple determinant.
      def key(tuple)
        @by.map{|by| tuple[by] }
      end

      # Returns the initial tuple to use for a given determinant.
      def init(key, tuple)
        tuple.each_with_object({}){|(k,v),h|
          h.merge!(k => summarizer(k).init(v))
        }
      end

      # Returns the summarizer to use for a given key.
      def summarizer(k)
        @sums[k] || Same.new
      end

      # Sums `tuple` on `memo`, returning the new tuple to use as memo.
      def sum(memo, tuple)
        tuple.each_with_object(memo.dup){|(k,v),h|
          h.merge!(k => summarizer(k).sum(h[k], v))
        }
      end

      # Terminates the summarization of a given tuple.
      def term(tuple)
        tuple.each_with_object({}){|(k,v),h|
          h.merge!(k => summarizer(k).term(v))
        }
      end

      def to_summarizer(x)
        case x
        when :same  then Same.new
        when :group then DistinctList.new
        else
          x
        end
      end

      #
      # Summarizes by enforcing that the same dependent is observed for a given
      # determinant, returning the dependent as summarization.
      #
      class Same

        def init(v)
          v
        end

        def sum(v1, v2)
          raise "Same values expected, got `#{v1}` vs. `#{v2}`" unless v1 == v2
          v1
        end

        def term(v)
          v
        end

      end # class Same

      #
      # Summarizes by putting distinct dependents inside an Array, ignoring nils,
      # and optionally sorting the array.
      #
      class DistinctList

        def initialize(&sorter)
          @sorter = sorter
        end

        def init(v)
          Set.new v.nil? ? [] : [v]
        end

        def sum(v1, v2)
          v1 << v2 unless v2.nil?
          v1
        end

        def term(v)
          v = v.to_a
          v = v.sort(&@sorter) if @sorter
          v
        end

      end # class DistinctList

      #
      # Summarizes by converting dependents to { x => y, ... } such that `x` is not
      # null and `y` is the value observed for `x`.
      #
      class YByX

        def initialize(y, x, preserve_nulls = false)
          @y = y
          @x = x
          @preserve_nulls = preserve_nulls
        end

        def init(v)
          [v]
        end

        def sum(v1, v2)
          v1 << v2
        end

        def term(v)
          h = {}
          v.each do |tuple|
            next if tuple[@x].nil?
            h[tuple[@x]] = tuple[@y] if not tuple[@y].nil? or @preserve_nulls
          end
          h
        end

      end # class YByX

      #
      # Summarizes by converting dependents to { x => [ys], ... } such that `x` is not
      # null and `[ys]` is a distinct list of observed non-null `y`.
      #
      class YsByX

        def initialize(y, x, &sorter)
          @y = y
          @x = x
          @sorter = sorter
        end

        def init(v)
          [v]
        end

        def sum(v1, v2)
          v1 << v2
        end

        def term(v)
          h = {}
          v = v.reject{|tuple| tuple[@x].nil? }
          v = v.sort(&@sorter) if @sorter
          v.each do |tuple|
            h[tuple[@x]] ||= []
            h[tuple[@x]] << tuple[@y]
            h[tuple[@x]].uniq!
          end
          h
        end

      end # class YsByX

    end # class Autosummarize
  end # module Operator
end # module Bmg
