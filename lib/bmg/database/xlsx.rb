module Bmg
  class Database
    class Xlsx < Database

      DEFAULT_OPTIONS = {
        reader_options: {}
      }

      def initialize(path, options = {})
        path = Path(path) if path.is_a?(String)
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def method_missing(name, *args, &bl)
        return super(name, *args, &bl) unless args.empty? && bl.nil?
        rel = rel_for(name)
        raise NotSuchRelationError(name.to_s) unless rel
        rel
      end

      def each_relation_pair
        return to_enum(:each_relation_pair) unless block_given?

        spreadsheet.sheets.each do |sheet_name|
          yield(sheet_name.to_sym, rel_for(sheet_name))
        end
      end

    protected

      def spreadsheet
        @spreadsheet ||= Roo::Spreadsheet.open(@path, @options)
      end

      def rel_for(sheet_name)
        Bmg.excel(@path, @options[:reader_options].merge({
          sheet: sheet_name.to_s
        }))
      end

    end # class Sequel
  end # class Database
end # module Bmg
