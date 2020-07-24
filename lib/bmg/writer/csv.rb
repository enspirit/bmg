module Bmg
  module Writer
    class Csv
      include Writer

      DEFAULT_OPTIONS = {
      }

      def initialize(options)
        @options = DEFAULT_OPTIONS.merge(options)
      end
      attr_reader :options

      def call(relation, string_or_io = nil)
        require 'csv'
        string_or_io, to_s = string_or_io.nil? ? [StringIO.new, true] : [string_or_io, false]
        headers = relation.type.to_attrlist if relation.type.knows_attrlist?
        csv = nil
        relation.each do |tuple|
          if csv.nil?
            headers = tuple.keys if headers.nil?
            csv = CSV.new(string_or_io, options.merge(headers: headers))
          end
          csv << headers.map{|h| tuple[h] }
        end
        to_s ? string_or_io.string : string_or_io
      end

    end # class Csv
  end # module Writer
end # module Bmg
