module Bmg
  class Summarizer
    #
    # Bucketizer summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.bucketize(:qty, :size => 2).summarize(...)
    #
    class Bucketize < Summarizer

      # Sets default options.
      def default_options
        { :size => 10 }
      end

      # Returns least value (defaults to "")
      def least()
        [[], []]
      end

      # Concatenates current memo with val.to_s
      def _happens(memo, val)
        memo.first << val
        memo
      end

      # Finalizes computation
      def finalize(memo)
        buckets = compute_buckets(memo.first, options[:size])
        buckets = touching_buckets(buckets) if options[:boundaries] == :touching
        buckets
      end

    private

      def compute_buckets(values, num_buckets = 10)
        sorted_values = values.compact.sort
        sorted_values = sorted_values.map{|v| v.to_s[0...options[:value_length]] } if options[:value_length]
        sorted_values = sorted_values.uniq if options[:distinct]

        # Calculate the size of each bucket
        total_values = sorted_values.length
        bucket_size = (total_values / num_buckets.to_f).ceil

        # Create the ranges for each bucket
        bucket_ranges = []
        num_buckets.times do |i|
          start_index = i * bucket_size
          break if start_index >= total_values  # Ensure we do not exceed the array bounds

          end_index = [(start_index + bucket_size - 1), total_values - 1].min
          start_value = sorted_values[start_index]
          end_value = sorted_values[end_index]
          bucket_ranges << (start_value..end_value)
        end

        bucket_ranges
      end

      def touching_buckets(buckets)
        result = []
        buckets.each do |b|
          r_start = result.empty? ? b.begin : result.last.end
          r_end = b.end
          result << (r_start...r_end)
        end
        result[-1] = (result.last.begin..result.last.end)

        result
      end

    end # class Concat

    # Factors a bucketize summarizer
    def self.bucketize(*args, &bl)
      Bucketize.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg
