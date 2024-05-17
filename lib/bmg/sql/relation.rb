module Bmg
  module Sql
    class Relation
      include Bmg::Relation

      def initialize(type, builder, expr)
        @type = type
        @builder = builder
        @expr = expr
      end

      attr_accessor :type

    protected

      attr_reader :expr, :builder

    public

      def bind(binding)
        expr = before_use(self.expr)
        expr = Processor::Bind.new(binding, builder).call(expr)
        _instance(type, builder, expr)
      end

      def each(&bl)
        raise NotImplementedError
      end

      def delete(*args, &bl)
        raise NotImplementedError
      end

      def insert(*args, &bl)
        raise NotImplementedError
      end

      def update(*args, &bl)
        raise NotImplementedError
      end

    protected ## optimization

      def _allbut(type, butlist)
        preserved_key = self.type.knows_keys? && self.type.keys.find{|k|
          (k & butlist).empty?
        }
        expr = before_use(self.expr)
        expr = Processor::Clip.new(butlist, true, :is_table_dee, builder).call(expr)
        expr = Processor::Distinct.new(builder).call(expr) unless preserved_key
        _instance(type, builder, expr)
      end

      def _constants(type, cs)
        expr = before_use(self.expr)
        expr = Processor::Constants.new(cs, builder).call(expr)
        _instance(type, builder, expr)
      end

      def _extend(type, extension)
        supported, unsupported = {}, {}
        extension.each_pair do |k,v|
          (v.is_a?(Symbol) ? supported : unsupported)[k] = v
        end
        if supported.empty?
          Operator::Extend.new(type, self, extension)
        elsif unsupported.empty?
          expr = Processor::Extend.new(supported, builder).call(self.expr)
          _instance(type, builder, expr)
        else
          expr = Processor::Extend.new(supported, builder).call(self.expr)
          operand = _instance(type.allbut(unsupported.keys), builder, expr)
          Operator::Extend.new(type, operand, unsupported)
        end
      end

      def _join(type, right, on)
        if right_expr = extract_compatible_sexpr(right)
          right_expr = Processor::Requalify.new(builder).call(right_expr)
          expr = before_use(self.expr)
          expr = Processor::Join.new(right_expr, on, {}, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      def _left_join(type, right, on, default_right_tuple)
        if right_expr = extract_compatible_sexpr(right)
          right_expr = Processor::Requalify.new(builder).call(right_expr)
          expr = before_use(self.expr)
          expr = Processor::Join.new(right_expr, on, {
            kind: :left,
            default_right_tuple: default_right_tuple
          }, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      def _matching(type, right, on)
        if right_expr = extract_compatible_sexpr(right)
          expr = before_use(self.expr)
          expr = Processor::SemiJoin.new(right_expr, on, false, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      def _not_matching(type, right, on)
        if right_expr = extract_compatible_sexpr(right)
          expr = before_use(self.expr)
          expr = Processor::SemiJoin.new(right_expr, on, true, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      def _page(type, ordering, page_index, options)
        pairs = Ordering.new(ordering).to_pairs
        limit  = options[:page_size] || Operator::Page::DEFAULT_OPTIONS[:page_size]
        offset = (page_index - 1) * limit
        expr = before_use(self.expr)
        expr = Processor::OrderBy.new(pairs, builder).call(expr)
        expr = Processor::LimitOffset.new(limit, offset, builder).call(expr)
        _instance(type, builder, expr)
      rescue Bmg::NotSupportedError
        super
      end

      def _project(type, attrlist)
        preserved_key = self.type.knows_keys? && self.type.keys.find{|k|
          k.all?{|a| attrlist.include?(a) }
        }
        expr = before_use(self.expr)
        expr = Processor::Clip.new(attrlist, false, :is_table_dee, builder).call(expr)
        expr = Processor::Distinct.new(builder).call(expr) unless preserved_key
        _instance(type, builder, expr)
      end

      def _rename(type, renaming)
        expr = before_use(self.expr)
        expr = Processor::Rename.new(renaming, builder).call(expr)
        _instance(type, builder, expr)
      end

      def _restrict(type, predicate)
        expr = before_use(self.expr)
        expr = Processor::Where.new(predicate, builder).call(expr)
        _instance(type, builder, expr)
      end

      def _summarize(type, by, defs)
        summarization = ::Bmg::Summarizer.summarization(defs)
        if can_compile_summarization?(summarization)
          expr = before_use(self.expr)
          expr = Processor::Summarize.new(by, summarization, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      def _transform(type, transformation, options)
        expr = before_use(self.expr)
        sup, unsup = Processor::Transform.split_supported(transformation){|x|
          [String, Integer, Float, Date, DateTime].include?(x)
        }
        return super if sup.nil?
        expr = Processor::Transform.new(sup, options, builder).call(expr)
        result = _instance(type, builder, expr)
        result = result.transform(unsup, options) if unsup
        result
      rescue Sql::NotSupportedError
        super
      end

      def can_compile_summarization?(summarization)
        summarization.values.all?{|s|
          [:avg, :count, :max, :min, :sum, :distinct_count].include?(s.to_summarizer_name)
        }
      end

      def _union(type, right, options)
        if right_expr = extract_compatible_sexpr(right)
          expr = before_use(self.expr)
          expr = Processor::Merge.new(:union, !!options[:all], right_expr, builder).call(expr)
          _instance(type, builder, expr)
        else
          super
        end
      end

      # Build a new relation instance for some new type & expression
      #
      # This method can be overriden by subclasses to provide their
      # own class instance
      def _instance(type, builder, expr)
        Relation.new(type, builder, expr)
      end

      # Provides subclasses with a chance to manipulate the expression
      # before it is reused in another one, following an algebra method
      # call
      def before_use(expr)
        expr
      end

      # Given a Relation operand (typically a right operand in a binary
      # expression), extract the associated `expr` if it is compatible
      # with self for optimization (e.g. same underlying engine).
      #
      # May return nil if operand should not be considered for further
      # optimization
      def extract_compatible_sexpr(operand)
        nil
      end

    public

      def to_sql
        expr.to_sql("", Dialect.default)
      end

      def to_ast
        [:sql, to_sql]
      end

      def to_s
        "(sql #{to_sql})"
      end
      alias :inspect :to_s

    end # class Relation
  end # module Sql
end # module Bmg
