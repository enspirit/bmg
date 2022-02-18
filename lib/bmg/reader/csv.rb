module Bmg
  module Reader
    class Csv
      include Reader

      DEFAULT_OPTIONS = {
        :headers => true,
        :return_headers => false,
        :smart => true
      }

      def initialize(type, path_or_io, options = {})
        require 'csv'

        @path_or_io = path_or_io
        @options = handle_options(options)
        @type = handle_type(type)
      end

      def each
        return to_enum unless block_given?

        with_csv do |csv|
          csv.each do |row|
            yield tuple(row)
          end
        end
      end

      def to_ast
        [ :csv, @path_or_io, @options ]
      end

      def to_s
        "(csv #{@path_or_io})"
      end
      alias :inspect :to_s

    private

      def tuple(row)
        row.to_hash.each_with_object({}){|(k,v),h| h[k.to_sym] = v }
      end

      def handle_type(type)
        return type if type.knows_attrlist?

        type.with_attrlist(infer_attrlist)
      end

      def infer_attrlist
        with_csv do |csv|
          csv.each do |row|
            return tuple(row).keys
          end
        end
      end

      def handle_options(options)
        options = DEFAULT_OPTIONS.merge(options)
        if options[:smart] && !@path_or_io.is_a?(IO)
          options[:col_sep] ||= infer_col_sep
          options[:quote_char] ||= infer_quote_char(options[:col_sep])
        end
        options
      end

      def infer_col_sep
        sniff(text_portion, [",","\t",";"], ",")
      end

      def infer_quote_char(col_sep)
        sniff(text_portion, ['"',"'"], '"'){|quote|
          /#{quote}#{col_sep}#{quote}|^#{quote}|#{quote}$/
        }
      end

      def text_portion
        @text_portion ||= with_io{|io| io.readlines(50).join("\n") }
      end

      def with_io(&bl)
        case @path_or_io
        when IO, StringIO
          @path_or_io.rewind if @path_or_io.respond_to?(:rewind)
          bl.call(@path_or_io)
        else
          File.open(@path_or_io, "r", &bl)
        end
      end

      def with_csv(&bl)
        with_io do |io|
          yield ::CSV.new(io, **csv_options)
        end
      end

      # Finds the best candidate among `candidates` for a separator
      # found in `str`. If none is found, returns `default`.
      def sniff(str, candidates, default, &bl)
        snif = {}
        candidates.each {|delim|
          counter = bl ? bl.call(delim) : delim
          snif[delim] = if counter.is_a?(Regexp)
            str.scan(counter).length
          else
            str.count(counter)
          end
        }
        snif = snif.sort {|a,b| b[1] <=> a[1] }
        snif.size > 0 ? snif[0][0] : default
      end

      def csv_options
        @csv_options ||= @options.dup.tap{|opts| opts.delete(:smart) }
      end

    end # class Csv
  end # module Reader
end # module Bmg
