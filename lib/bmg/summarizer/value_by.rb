module Bmg
  class Summarizer
    #
    # ValueBy summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.value_by(:qty, :by => :serie).summarize(...)
    #
    class ValueBy < Summarizer

      DEFAULT_OPTIONS = {
        :symbolize => false
      }

      # Returns {} as least value.
      def least
        {}
      end

      # Collects the value
      def happens(memo, tuple)
        by = tuple[options[:by]]
        by = by.to_sym if by && options[:symbolize]
        misuse!(tuple, memo) if memo.has_key?(by)
        memo.tap{|m|
          m[by] = extract_value(tuple)
        }
      end

      # Finalizes the computation.
      def finalize(memo)
        default_tuple.merge(memo)
      end

    private

      def default_tuple
        (options[:series] || []).each_with_object({}){|s,ss|
          s_def = options[:default]
          s = s.to_sym if s && options[:symbolize]
          ss[s] = s_def
        }
      end

      def misuse!(tuple, memo)
        msg = "Summarizer.value_by: summarization key + the serie must form be a candidate key"
        msg += "\n"
        msg += "  Tuple: #{tuple.inspect}"
        msg += "  Memo:  #{memo.inspect}"
        raise MisuseError, msg
      end

    end # class ValueBy

    def self.value_by(*args, &bl)
      ValueBy.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg
