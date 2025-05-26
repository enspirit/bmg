module Bmg
  module Writer
    class Text
      include Writer

      TupleLike    = lambda{|t| t.is_a?(Hash) || (defined?(OpenStruct) && t.is_a?(OpenStruct)) }
      RelationLike = lambda{|r| r.is_a?(Relation) || (r.is_a?(Enumerable) && r.all?{|t| TupleLike === t }) }

      module Utils

        def max(x, y)
          return y if x.nil?
          return x if y.nil?
          x > y ? x : y
        end
      end
      include Utils

      class Cell
        include Utils

        def initialize(renderer, value)
          @renderer = renderer
          @value = value
        end

        def min_width
          @min_width ||= rendering_lines.inject(0) do |maxl,line|
            max(maxl,line.size)
          end
        end

        def rendering_lines(size = nil)
          if size.nil?
            text_rendering.split(/\n/)
          elsif @value.is_a?(Numeric)
            rendering_lines(nil).map{|l| "%#{size}s" % l}
          else
            rendering_lines(nil).map{|l| "%-#{size}s" % l}
          end
        end

        def text_rendering
          @text_rendering ||= case (value = @value)
            when NilClass
              "[nil]"
            when Symbol
              value.inspect
            when Float
              (@renderer.text_options[:float_format] || "%.3f") % value
            when Hash
              value.inspect
            when RelationLike
              @renderer.render(value, "")
            when Array
              array_rendering(value)
            when Time, DateTime
              value.to_s
            else
              value.to_s
          end
        end

        def array_rendering(value)
          if TupleLike === value.first
            @renderer.render(value, "")
          elsif value.empty?
            "[]"
          else
            values = value.map{|x| Cell.new(x).text_rendering}
            if values.inject(0){|memo,s| memo + s.size} < 20
              "[" + values.join(", ") + "]"
            else
              "[" + values.join(",\n ") + "]"
            end
          end
        end

      end # class Cell

      class Row
        include Utils

        def initialize(renderer, values)
          @renderer = renderer
          @cells = values.map{|v| Cell.new(renderer, v) }
        end

        def min_widths
          @cells.map{|cell| cell.min_width}
        end

        def rendering_lines(sizes = min_widths)
          nb_lines = 0
          by_cell = @cells.zip(sizes).map do |cell,size|
            lines = cell.rendering_lines(size)
            nb_lines = max(nb_lines, lines.size)
            lines
          end
          grid = (0...nb_lines).map do |line_i|
            "| " + by_cell.zip(sizes).map{|cell_lines, size|
              cell_lines[line_i] || " "*size
            }.join(" | ") + " |"
          end
          grid.empty? ? ["|  |"] : grid
        end

      end # class Row

      class Table
        include Utils

        def initialize(renderer, records, attributes)
          @renderer = renderer
          @header = Row.new(renderer, attributes.map(&:to_s))
          @rows = records.map{|r| Row.new(renderer, r) }
        end
        attr_reader :renderer, :header, :rows

        def sizes
          @sizes ||= rows.inject(header.min_widths) do |memo,row|
            memo.zip(row.min_widths).map{|x,y| max(x,y)}
          end
        end

        def sep
          @sep ||= '+-' << sizes.map{|s| '-' * s}.join('-+-') << '-+'
        end

        def each_line(pretty = renderer.text_options[:pretty])
          if pretty && trim = renderer.text_options[:trim_at]
            each_line(false) do |line|
              yield(line[0..trim])
            end
          else
            yield(sep)
            yield(header.rendering_lines(sizes).first)
            yield(sep)
            rows.each do |row|
              row.rendering_lines(sizes).each do |line|
                yield(line)
              end
            end
            yield(sep)
          end
        end

        def each
          return to_enum unless block_given?
          each_line do |line|
            yield(line.strip << "\n")
          end
        end

        def to_s
          each.each_with_object(""){|line,buf| buf << line}
        end

      end # class Table


      DEFAULT_OPTIONS = {
      }

      def initialize(text_options = {}, output_preferences = nil)
        @text_options = DEFAULT_OPTIONS.merge(text_options)
        @output_preferences = OutputPreferences.dress(output_preferences)
      end
      attr_reader :text_options, :output_preferences

      def call(relation, output = "")
        each_line(relation) do |str|
          output << str
        end
        output
      end
      alias :render :call

    private

      def each_line(relation, &bl)
        input    = relation
        input    = [input.to_hash] if TupleLike === input
        relation = input.to_a
        attrs    = relation.inject([]){|memo,t| (memo | t.keys) }
        records  = relation.map{|t| attrs.map{|a| t[a]} }
        table    = Table.new(self, records, attrs)
        table.each(&bl)
      end

    end # class Text
  end # module Writer
  module Relation

    def to_text(options = {}, preferences = {}, output = "")
      Writer::Text.new(options, preferences).render(self, output)
    end

  end # module Relation
end # module Bmg
