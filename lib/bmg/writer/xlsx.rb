module Bmg
  module Writer
    class Xlsx
      include Writer

      DEFAULT_OPTIONS = {
      }

      def initialize(xlsx_options, output_preferences = nil)
        @xlsx_options = DEFAULT_OPTIONS.merge(xlsx_options)
        @output_preferences = OutputPreferences.dress(output_preferences)
      end
      attr_reader :xlsx_options, :output_preferences

      def call(relation, path)
        require 'write_xlsx'
        dup._call(relation, path)
      end

    protected
      attr_reader :workbook, :worksheet

      def _call(relation, path)
        @workbook = xlsx_options[:workbook] || WriteXLSX.new(path)
        @worksheet = xlsx_options[:worksheet] || workbook.add_worksheet

        headers = infer_headers(relation.type)
        before = nil
        each_tuple(relation) do |tuple,i|
          headers = infer_headers(tuple) if headers.nil?
          headers.each_with_index do |h,i|
            worksheet.write_string(0, i, h)
          end if i == 0
          before, tuple = output_preferences.erase_redundance_in_group(before, tuple)
          headers.each_with_index do |h,j|
            meth, *args = write_pair(tuple[h])
            worksheet.send(meth, 1+i, j, *args)
          end
        end

        workbook.close unless xlsx_options[:workbook]
        path
      end

      def write_pair(value)
        case value
        when Numeric
          [:write_number, value]
        when Date
          [:write_date_time, value, date_format]
        else
          [:write_string, value.to_s]
        end
      end

      def date_format
        @date_format ||= workbook.add_format(:num_format => 'yyyy-mm-dd')
      end

    end # class Xlsx
  end # module Writer
  module Relation

    def to_xlsx(options = {}, path = nil, preferences = nil)
      options, path = {}, options unless options.is_a?(Hash)
      Writer::Xlsx.new(options, preferences).call(self, path)
    end

  end # module Relation
end # module Bmg
