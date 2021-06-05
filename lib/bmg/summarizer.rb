module Bmg
  #
  # Summarizer.
  #
  # This class provides a basis for implementing aggregation operators.
  #
  # Aggregation operators are made available through factory methods on the
  # Summarizer class itself:
  #
  #     Summarizer.count
  #     Summarizer.sum(:qty)
  #     Summarizer.sum{|t| t[:qty] * t[:price] }
  #
  # Once built, summarizers can be used either in black-box or white-box modes.
  #
  #     relation = ...
  #     agg = Summarizer.sum(:qty)
  #
  #     # Black box mode:
  #     result = agg.summarize(relation)
  #
  #     # White box mode:
  #     memo = agg.least
  #     relation.each do |tuple|
  #       memo = agg.happens(memo, tuple)
  #     end
  #     result = agg.finalize(memo)
  #
  class Summarizer

    # @return Aggregation options as a Hash
    attr_reader :options

    # @return the underlying functor, either a Symbol or a Proc
    attr_reader :functor

    # Creates an Summarizer instance.
    #
    # Private method, please use the factory methods
    def initialize(*args, &block)
      @options = default_options
      args.push(block) if block
      args.each do |arg|
        case arg
        when Symbol, Proc then @functor = arg
        when Hash         then @options = @options.merge(arg)
        else
          raise ArgumentError, "Unexpected `#{arg}`"
        end
      end
    end

    # Converts some summarization definitions to a Hash of
    # summarizers.
    def self.summarization(defs)
      Hash[defs.map{|k,v|
        summarizer = case v
        when Summarizer then v
        when Symbol     then Summarizer.send(v, k)
        when Proc       then Summarizer.by_proc(&v)
        else
          raise ArgumentError, "Unexpected summarizer #{k} => #{v}"
        end
        [ k, summarizer ]
      }]
    end

    # Returns the default options to use
    #
    # @return the default aggregation options
    def default_options
      {}
    end
    protected :default_options

    # Returns the least value, which is the one to use on an empty
    # set.
    #
    # This method is intended to be overriden by subclasses; default
    # implementation returns nil.
    #
    # @return the least value for this summarizer
    def least
      nil
    end

    # This method is called on each aggregated tuple and must return
    # an updated _memo_ value. It can be seen as the block typically
    # given to Enumerable.inject.
    #
    # The default implementation collects the pre-value on the tuple
    # and delegates to _happens.
    #
    # @param memo the current aggregation value
    # @param the current iterated tuple
    # @return updated memo value
    def happens(memo, tuple)
      value = extract_value(tuple)
      _happens(memo, value)
    end

    # @see happens.
    #
    # This method is intended to be overriden and returns _value_
    # by default, making this summarizer a "Last(...)" summarizer.
    def _happens(memo, value)
      value
    end
    protected :_happens

    # This method finalizes an aggregation.
    #
    # Argument _memo_ is either _least_ or the result of aggregating
    # through _happens_. The default implementation simply returns
    # _memo_. The method is intended to be overriden for complex
    # aggregations that need statefull information such as `avg`.
    #
    # @param [Object] memo the current aggregation value
    # @return [Object] the aggregation value, as finalized
    def finalize(memo)
      memo
    end

    # Summarizes an enumeration of tuples.
    #
    # @param an enumerable of tuples
    # @return the computed summarization value
    def summarize(enum)
      finalize(enum.inject(least){|m,t| happens(m, t) })
    end

    # Returns the canonical summarizer name
    def to_summarizer_name
      self.class.name.downcase[/::([a-z]+)$/, 1].to_sym
    end

  protected

    def extract_value(tuple)
      value = case @functor
      when Proc
        @functor.call(tuple)
      when NilClass
        tuple
      when Symbol
        tuple[@functor]
      else
        tuple[@functor]
      end
    end

  end # class Summarizer
end # module Bmg
require_relative 'summarizer/count'
require_relative 'summarizer/sum'
require_relative 'summarizer/min'
require_relative 'summarizer/max'
require_relative 'summarizer/avg'
require_relative 'summarizer/variance'
require_relative 'summarizer/stddev'
require_relative 'summarizer/percentile'
require_relative 'summarizer/collect'
require_relative 'summarizer/distinct'
require_relative 'summarizer/concat'
require_relative 'summarizer/by_proc'
require_relative 'summarizer/multiple'
require_relative 'summarizer/value_by'
