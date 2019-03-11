module Bmg
  class Summarizer
    #
    # String concatenation summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.concat(:qty).summarize(...)
    #
    class Concat < Summarizer

      # Sets default options.
      def default_options
        {:before => "", :after => "", :between => ""}
      end

      # Returns least value (defaults to "")
      def least()
        ""
      end

      # Concatenates current memo with val.to_s
      def _happens(memo, val) 
        memo << options[:between].to_s unless memo.empty?
        memo << val.to_s
      end

      # Finalizes computation
      def finalize(memo)
        options[:before].to_s + memo + options[:after].to_s
      end

    end # class Concat

    # Factors a concatenation summarizer
    def self.concat(*args, &bl)
      Concat.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg
