module Bmg
  module Operator
    #
    # Page operator.
    #
    # Takes the n-th page according to some tuple ordering and page size
    #
    class Page
      include Operator::Unary

      DEFAULT_OPTIONS = {

        page_size: 100

      }

      def initialize(type, operand, ordering, page_index, options)
        raise ArgumentError, "Page index must be > 0" if page_index <= 0
        @type = type
        @operand = operand
        @ordering = ordering
        @page_index = page_index
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :ordering, :page_index, :options

    public

      def each(&bl)
        page_size = options[:page_size]
        @operand.to_a
          .sort(&comparator)
          .drop(page_size * (page_index-1))
          .take(page_size)
          .each(&bl)
      end

      def to_ast
        [ :page, operand.to_ast, ordering.dup, page_index, options.dup ]
      end

    protected ### inspect

      def comparator
        ->(t1, t2) {
          ordering.each do |(attr,direction)|
            c = t1[attr] <=> t2[attr]
            return (direction == :desc ? -c : c) unless c==0
          end
          0
        }
      end

      def args
        [ ordering, page_index, options ]
      end

    end # class Page
  end # module Operator
end # module Bmg
