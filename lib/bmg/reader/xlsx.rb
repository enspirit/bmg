module Bmg
  module Reader
    class Excel
      include Reader

      DEFAULT_OPTIONS = {
        sheet: 0,
        skip: 0,
        row_num: true,
        grouping_character: nil,
      }

      def initialize(type, path, options = {})
        require 'roo'
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
        @type = type.knows_attrlist? ? type : type.with_attrlist(infer_attrlist)
      end

      def each
        return to_enum unless block_given?

        headers = type.attrlist
        headers = headers[1..-1] if generate_row_num?
        start_at = @options[:skip] + 2
        end_at = spreadsheet.last_row

        previous = {}
        (start_at..end_at).each do |i|
          row = spreadsheet.row(i)
          init = init_tuple(i - start_at + 1)
          tuple = (0...headers.size).each_with_object(init){|i,t|
            t[headers[i]] = extract_value(headers[i], row[i], previous)
          }
          yield(tuple)
          previous = tuple
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

      def spreadsheet
        @spreadsheet ||= Roo::Spreadsheet
          .open(@path, @options)
          .sheet(@options[:sheet])
      end

      def infer_attrlist
        row = spreadsheet.row(1+@options[:skip])
        attrlist = row.map{|c| c.to_s.strip.to_sym }
        attrlist.unshift(row_num_name) if generate_row_num?
        attrlist
      end

      def generate_row_num?
        !!@options[:row_num]
      end

      def row_num_name
        case as = @options[:row_num]
        when TrueClass  then :row_num
        when Symbol     then as
        else nil
        end
      end

      def init_tuple(i)
        return {} unless generate_row_num?

        { row_num_name => i }
      end

      def extract_value(attribute, value, previous)
        return value unless c = @options[:grouping_character]

        value == c ? previous[attribute] : value
      end

    end # class Excel
  end # module Reader
end # module Bmg
