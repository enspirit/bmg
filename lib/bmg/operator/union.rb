module Bmg
  module Operator
    #
    # Union operator.
    #
    # Returns all tuples of the left operand followed by all
    # tuples from the right operand.
    #
    # This implementation is actually a NAry-Union, since it handles
    # an arbitrary number of operands.
    #
    # By default, this operator strips duplicates, as of relational
    # theory. Please set the `:all` option to true to avoid this
    # behavior and save execution time.
    #
    class Union
      include Operator

      DEFAULT_OPTIONS = {
        all: false
      }

      def initialize(type, operands, options = {})
        @type = type
        @operands = operands
        @options = DEFAULT_OPTIONS.merge(options)
      end
      attr_reader :type

    protected

      attr_reader :operands, :options

    public

      def all?
        @options[:all]
      end

      def each(&bl)
        if all?
          operands.each do |op|
            op.each(&bl)
          end
        else
          seen = {}
          operands.each do |op|
            op.each do |tuple|
              yield(tuple) unless seen.has_key?(tuple)
              seen[tuple] = true
            end
          end
        end
      end

    protected ### optimization

      def _restrict(type, predicate)
        Union.new(type, operands.map{|op| op.restrict(predicate) }, options)
      end

      def _union(type, other, options)
        norm_options = DEFAULT_OPTIONS.merge(options)
        return super unless norm_options == self.options
        case other
        when Union
          return super unless norm_options == other.send(:options)
          Union.new(type, operands + other.operands, options)
        else
          Union.new(type, operands + [other], options)
        end
      end

    end # class Union
  end # module Operator
end # module Bmg
