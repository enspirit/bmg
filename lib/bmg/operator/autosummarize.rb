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
      include Operator::Unary

      DEFAULT_OPTIONS = {
        default: :same
      }

      def initialize(type, operand, by, sums, options = {})
        @type = type
        @operand = operand
        @by = by
        @sums = sums.each_with_object({}){|(k,v),h| h[k] = to_summarizer(v) }
        @options = DEFAULT_OPTIONS.merge(options)
        @algo = build_algo
      end

    protected

      attr_reader :by, :sums, :options

    public

      def self.same(*args)
        Same.new(*args)
      end

      def self.group(*args)
        Group.new(*args)
      end

      def self.y_by_x(*args)
        YByX.new(*args)
      end

      def self.ys_by_x(*args)
        YsByX.new(*args)
      end

      def each(&bl)
        return to_enum unless block_given?
        h = {}
        @operand.each do |tuple|
          key = key(tuple)
          h[key] ||= @algo.init(tuple)
          h[key] = @algo.sum(h[key], tuple)
        end
        h.each_pair do |k,v|
          h[k] = @algo.term(v)
        end
        h.values.each(&bl)
      end

      def to_ast
        [:autosummarize, operand.to_ast, by.dup, sums.dup, options.dup]
      end

    public ### for internal reasons

      def _count
        operand._count
      end

    protected

      def _restrict(type, predicate)
        top, bottom = predicate.and_split(sums.keys)
        if top == predicate
          super
        else
          op = operand
          op = op.restrict(bottom)
          op = op.autosummarize(by, sums, options)
          op = op.restrict(top)
          op
        end
      end

    protected ### inspect

      def args
        [ by, sums ]
      end

    private

      def build_algo
        case default = @options[:default]
        when :same  then Check.new(sums)
        when :first then Trust.new(sums)
        else
          raise ArgumentError, "Unknown default summarizer: `#{default}`"
        end
      end

      # Returns the tuple determinant.
      def key(tuple)
        @by.map{|by| tuple[by] }
      end

      def to_summarizer(x)
        case x
        when :same  then Same::INSTANCE
        when :group then DistinctList::INSTANCE
        else
          x
        end
      end

      class Check
        def initialize(sums)
          @sums = sums
        end
        attr_reader :sums

        def summarizer(k)
          @sums[k] ||= Same::INSTANCE
        end

        def init(tuple)
          tuple.each_with_object({}){|(k,v),h|
            h.merge!(k => summarizer(k).init(v))
          }
        end

        def sum(memo, tuple)
          tuple.each_with_object(memo.dup){|(k,v),h|
            h.merge!(k => summarizer(k).sum(h[k], v))
          }
        end

        def term(tuple)
          tuple.each_with_object({}){|(k,v),h|
            h.merge!(k => summarizer(k).term(v))
          }
        end
      end # class Check

      class Trust
        def initialize(sums)
          @sums = sums
        end
        attr_reader :sums

        # Returns the initial tuple to use for a given determinant.
        def init(tuple)
          sums.each_with_object(tuple.dup){|(attribute,summarizer),new_tuple|
            new_tuple[attribute] = summarizer.init(tuple[attribute])
          }
        end

        # Sums `tuple` on `memo`, returning the new tuple to use as memo.
        def sum(memo, tuple)
          sums.each_with_object(memo.dup){|(attribute,summarizer),new_tuple|
            new_tuple[attribute] = summarizer.sum(memo[attribute], tuple[attribute])
          }
        end

        # Terminates the summarization of a given tuple.
        def term(tuple)
          sums.each_with_object(tuple.dup){|(attribute,summarizer),new_tuple|
            new_tuple[attribute] = summarizer.term(tuple[attribute])
          }
        end
      end # class Trust

      #
      # Summarizes by enforcing that the same dependent is observed for a given
      # determinant, returning the dependent as summarization.
      #
      class Same

        def init(v)
          v
        end

        def sum(v1, v2)
          raise TypeError, "Same values expected, got `#{v1}` vs. `#{v2}`" unless v1 == v2
          v1
        end

        def term(v)
          v
        end

        def inspect
          ":same"
        end
        alias :to_s :inspect

        INSTANCE = new
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

        def inspect
          ":group"
        end
        alias :to_s :inspect

        INSTANCE = new
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
          v.nil? ? [] : [v]
        end

        def sum(v1, v2)
          v2.nil? ? v1 : (v1 << v2)
        end

        def term(v)
          h = {}
          v.each do |tuple|
            next if tuple[@x].nil?
            h[tuple[@x]] = tuple[@y] if not tuple[@y].nil? or @preserve_nulls
          end
          h
        end

        def inspect
          ":#{@y}_by_#{@x}"
        end
        alias :to_s :inspect

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
          v.nil? ? [] : [v]
        end

        def sum(v1, v2)
          v2.nil? ? v1 : (v1 << v2)
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

        def inspect
          ":#{@y}s_by_#{@x}"
        end
        alias :to_s :inspect

      end # class YsByX

    end # class Autosummarize
  end # module Operator
end # module Bmg
