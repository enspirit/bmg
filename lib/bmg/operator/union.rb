module Bmg
  module Operator
    #
    # Union operator.
    #
    # Returns all tuples of the left operand followed by all
    # tuples from the right operand.
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

      def initialize(type, left, right, options = {})
        @type = type
        @left = left
        @right = right
        @options = DEFAULT_OPTIONS.merge(options)
      end

    private

      attr_reader :type, :left, :right, :options

    public

      def all?
        @options[:all]
      end

      def each(&bl)
        if all?
          @left.each(&bl)
          @right.each(&bl)
        else
          seen = {}
          @left.each do |tuple|
            yield(tuple)
            seen[tuple] = true
          end
          @right.each do |tuple|
            yield(tuple) unless seen.has_key?(tuple)
          end
        end
      end

    end # class Union
  end # module Operator
end # module Bmg
