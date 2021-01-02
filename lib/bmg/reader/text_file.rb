module Bmg
  module Reader
    class TextFile
      include Reader

      DEFAULT_OPTIONS = {
        strip: true,
        parse: nil
      }

      def initialize(type, path, options = {})
        options = { parse: options } if options.is_a?(Regexp)
        @path = path
        @options = DEFAULT_OPTIONS.merge(options)
        @type = infer_type(type)
      end
      attr_reader :path, :options

    public # Relation

      def each
        path.each_line.each_with_index do |text, line|
          text = text.strip if strip?
          parsed = parse(text)
          yield({line: 1+line}.merge(parsed)) if parsed
        end
      end

    private

      def infer_type(base)
        return base unless base == Bmg::Type::ANY
        attr_list = if rx = options[:parse]
          [:line] + rx.names.map(&:to_sym)
        else
          [:line, :text]
        end
        base
          .with_attrlist(attr_list)
          .with_keys([[:line]])
      end

      def strip?
        options[:strip]
      end

      def parse(text)
        return { text: text } unless rx = options[:parse]
        if match = rx.match(text)
          TupleAlgebra.symbolize_keys(match.named_captures)
        end
      end

    end # class TextFile
  end # module Reader
end # module Bmg
