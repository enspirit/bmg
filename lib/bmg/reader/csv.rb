module Bmg
  module Reader
    class Csv
      include Reader

      DEFAULT_OPTIONS = {
        :headers => true,
        :return_headers => false
      }

      def initialize(type, path, options = {})
        @type = type
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
        @options[:col_sep] ||= infer_col_sep
        @options[:quote_char] ||= infer_quote_char
      end

      def each
        require 'csv'
        ::CSV.foreach(@path, @options) do |row|
          yield tuple(row)
        end
      end

      def to_ast
        [ :csv, @path, @options ]
      end

    private

      def tuple(row)
        row.to_hash.each_with_object({}){|(k,v),h| h[k.to_sym] = v }
      end

      def infer_col_sep
        sniff(text_portion, [",","\t",";"], ",")
      end

      def infer_quote_char
        sniff(text_portion, ["'","\""], "\"")
      end

      def text_portion
        @text_portion ||= File.foreach(@path).first(10).join("\n")
      end

      # Finds the best candidate among `candidates` for a separator
      # found in `str`. If none is found, returns `default`.
      def sniff(str, candidates, default)
        snif = {}
        candidates.each {|delim|
          snif[delim] = str.count(delim)
        }
        snif = snif.sort {|a,b| b[1] <=> a[1] }
        snif.size > 0 ? snif[0][0] : default
      end

    end # class Csv
  end # module Reader
end # module Bmg
