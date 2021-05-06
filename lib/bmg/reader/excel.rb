module Bmg
  module Reader
    class Excel
      include Reader

      DEFAULT_OPTIONS = {
        skip: 0,
        row_num: true
      }

      def initialize(type, path, options = {})
        @type = type
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def each
        return to_enum unless block_given?
        require 'roo'
        xlsx = Roo::Spreadsheet.open(@path, @options)
        headers = nil
        xlsx.sheet(0)
          .each
          .drop(@options[:skip])
          .each_with_index
          .each do |row, i|
            if i==0
              headers = row.map(&:to_sym)
            else
              init = init_tuple(i)
              tuple = (0...headers.size)
                .each_with_object(init){|i,t|
                  t[headers[i]] = row[i]
                }
              yield(tuple)
            end
          end
      end

      def to_ast
        [ :excel, @path, @options ]
      end

      def to_s
        "(excel #{@path})"
      end
      alias :inspect :to_s

    private

      def init_tuple(i)
        case as = @options[:row_num]
        when TrueClass
          { :row_num => i }
        when FalseClass
          {}
        when Symbol
          { :"#{as}" => i }
        end
      end

    end # class Excel
  end # module Reader
end # module Bmg