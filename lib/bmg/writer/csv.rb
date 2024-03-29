module Bmg
  module Writer
    class Csv
      include Writer

      DEFAULT_OPTIONS = {
      }

      def initialize(csv_options, output_preferences = nil)
        @csv_options = DEFAULT_OPTIONS.merge(csv_options)
        @output_preferences = OutputPreferences.dress(output_preferences)
      end
      attr_reader :csv_options, :output_preferences

      def call(relation, string_or_io = nil)
        require 'csv'
        string_or_io, to_s = string_or_io.nil? ? [StringIO.new, true] : [string_or_io, false]
        headers, csv = infer_headers(relation.type), nil
        previous = nil
        each_tuple(relation) do |tuple,i|
          if csv.nil?
            headers = infer_headers(tuple) if headers.nil?
            csv_opts = csv_options.merge(headers: headers)
            csv = CSV.new(string_or_io, **csv_opts)
          end
          previous, tuple = output_preferences.erase_redundance_in_group(previous, tuple)
          csv << headers.map{|h| tuple[h] }
        end
        to_s ? string_or_io.string : string_or_io
      end

    end # class Csv
  end # module Writer
end # module Bmg
