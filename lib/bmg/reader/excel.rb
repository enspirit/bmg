module Bmg
  module Reader
    class Excel
      include Reader

      DEFAULT_OPTIONS = {
        skip: 0
      }

      def initialize(path, options = {})
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def each
        require 'roo'
        xlsx = Roo::Spreadsheet.open(@path)
        headers = nil
        xlsx.sheet(0)
          .each
          .drop(@options[:skip])
          .each_with_index
          .each do |row, i|
            if i==0
              headers = row.map(&:to_sym)
            else
              tuple = (0...headers.size).each_with_object({}){|i,t| t[headers[i]] = row[i] }
              yield(tuple)
            end
          end
      end

    end # class Excel
  end # module Reader
end # module Bmg