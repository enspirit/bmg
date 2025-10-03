module Bmg
  module Writer
    class Xlsx
      include Writer

      DEFAULT_OPTIONS = {
      }

      def initialize(xlsx_options, output_preferences = nil)
        require 'write_xlsx'
        @xlsx_options = DEFAULT_OPTIONS.merge(xlsx_options)
        @output_preferences = OutputPreferences.dress(output_preferences)
      end
      attr_reader :xlsx_options, :output_preferences

      def call(relation, path)
        dup._call(relation, path)
      end

      def self.to_xlsx(database, path)
        require 'write_xlsx'
        workbook = WriteXLSX.new(path)
        database.each_relation_pair do |name, rel|
          worksheet = workbook.add_worksheet(name)
          rel.to_xlsx({
            workbook: workbook,
            worksheet: worksheet,
          }, nil, database.output_preferences_for(name))
        end
        workbook.close
      end

    protected
      attr_reader :workbook, :worksheet

      def _call(relation, path)
        @workbook = xlsx_options[:workbook] || WriteXLSX.new(path)
        @worksheet = xlsx_options[:worksheet] || workbook.add_worksheet
        @worksheet = workbook.add_worksheet(@worksheet) if @worksheet.is_a?(String)

        headers = infer_headers(relation.type)
        before = nil
        max_widths = Hash.new{|h,k| h[k] = 5 }

        header_format = workbook.add_format(bold: true)
        each_tuple(relation) do |tuple,i|
          headers = infer_headers(tuple) if headers.nil?
          headers.each_with_index do |h,i|
            worksheet.write_string(0, i, h, header_format)
            max_widths[i] = [max_widths[i], h.to_s.size].max
          end if i == 0
          before, tuple = output_preferences.erase_redundance_in_group(before, tuple)
          headers.each_with_index do |h,j|
            meth, args, approx_width = write_pair(tuple[h])
            worksheet.send(meth, 1+i, j, *args)
            max_widths[j] = [max_widths[j], approx_width].max
          end
        end

        max_widths.each_pair do |col, width|
          worksheet.set_column(col, col, [1+width, 100].min)
        end
        worksheet.freeze_panes(1, 0)
        workbook.close unless xlsx_options[:workbook]
        path
      end

      def write_pair(value)
        case value
        when Numeric
          [:write_number, [value], value.to_s.size]
        when Date
          [:write_date_time, [value, date_format], value.to_s.size]
        else
          [:write_string, [value.to_s], value.to_s.size]
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
