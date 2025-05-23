module Bmg
  module Operator
    #
    # Generator operator.
    #
    # Generates a relation. Most inspired by PostgreSQL's generate_series.
    #
    class Generator
      include Operator::Zeroary

      DEFAULT_OPTIONS = {
        :as => :i,
        :step => 1,
      }

      def initialize(type, from, to, options = {})
        options = { step: options } unless options.is_a?(Hash)
        @type = type
        @from = from
        @to = to
        @options = DEFAULT_OPTIONS.merge(options)
        raise ArgumentError, "from, to and step must be defined" if from.nil? || to.nil? || step.nil?
      end
      attr_reader :from, :to, :options

      def each
        return to_enum unless block_given?

        current = from
        as = options[:as]

        until overflowed?(current)
          yield({ as => current })
          current = next_of(current)
        end
      end

    private

      def step
        @step ||= options[:step]
      end

      def positive_step?
        !step.is_a?(Numeric) || step > 0
      end

      def next_of(current)
        step.is_a?(Proc) ? step.call(current) : current + step
      end

      def overflowed?(current)
        positive_step? ? current > to : current < to
      end

    protected ### inspect

      def operands
        []
      end

      def args
        [ from, to, options ]
      end

    end # class Generator
  end # module Operator
end # module Bmg
