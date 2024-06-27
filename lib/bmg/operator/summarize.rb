module Bmg
  module Operator
    #
    # Summarize operator.
    #
    # Makes a summarization by some attributes, applying aggregations
    # to the corresponding images.
    #
    class Summarize
      include Operator::Unary

      def initialize(type, operand, by, summarization)
        @type = type
        @operand = operand
        @by = by
        @summarization = Summarizer.summarization(summarization)
      end

    protected

      attr_reader :by, :summarization

    protected # optimization

      def _restrict(type, predicate)
        return super unless type.knows_attrlist?

        # bottom only uses attributes of the `by` list
        # and can be pushed down the tree
        summaries = type.attrlist - by
        top, bottom = predicate.and_split(summaries)
        if top == predicate
          super
        else
          op = operand
          op = op.restrict(bottom)
          op = op.summarize(by, summarization)
          op = op.restrict(top)
          op
        end
      end

    public

      def each
        return to_enum unless block_given?
        # summary key => summarization memo, starting with least
        result = Hash.new{|h,k|
          h[k] = Hash[@summarization.map{|k,v|
            [ k, v.least ]
          }]
        }
        # iterate each tuple
        @operand.each do |tuple|
          key = TupleAlgebra.project(tuple, @by)
          # apply them all and create a new memo
          result[key] = Hash[@summarization.map{|k,v|
            [ k, v.happens(result[key][k], tuple) ]
          }]
        end
        # Merge result keys and values
        result.each_pair do |by,sums|
          tuple = Hash[@summarization.map{|k,v|
            [ k, v.finalize(sums[k]) ]
          }].merge(by)
          yield(tuple)
        end
      end

      def to_ast
        [ :summarize, operand.to_ast, by, summarization ]
      end

    protected ### inspect

      def args
        [ by, summarization ]
      end

    end # class Summarize
  end # module Operator
end # module Bmg
