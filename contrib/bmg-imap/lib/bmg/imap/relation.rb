module Bmg
  module Imap
    class Relation
      include Bmg::Relation

      ATTRLIST = [
        :uid, :mailbox, :date, :subject,
        :from, :to, :cc, :bcc, :reply_to,
        :in_reply_to, :message_id,
        :labels, :flags, :size, :body_text,
      ].freeze

      DEFAULT_TYPE = Type::ANY.with_attrlist(ATTRLIST)

      def initialize(type, options)
        @type = type
        @options = options
        @connection = options[:connection] || Connection.new(@options)
        @provider = options[:provider] || Provider.infer_from_host(options[:host])
        @mailboxes = nil
        @search_criteria = nil
        @fetch_body = true
      end
      attr_accessor :type
      attr_reader :connection

    public

      def each(&bl)
        return to_enum unless block_given?

        connection.each_email(@mailboxes, @search_criteria, fetch_body: @fetch_body, &bl)
      end

      def to_ast
        [ :imap, @options[:host] ]
      end

      def to_s
        mbox = @mailboxes ? @mailboxes.join(",") : "*"
        "(imap #{@options[:host]}/#{mbox})"
      end
      alias :inspect :to_s

    protected

      def _restrict(type, predicate)
        mailboxes, criteria, remaining = PredicateTranslator.new(@provider, timezone: @options[:timezone]).call(predicate)

        # Only push IMAP search criteria when the connection supports them
        unless connection.supports_search_criteria?
          remaining = criteria ? combine_remaining(remaining, criteria, predicate) : remaining
          criteria = nil
        end

        if mailboxes || criteria
          restricted = dup
          restricted.instance_variable_set(:@type, type)
          restricted.instance_variable_set(:@mailboxes, merge_mailboxes(mailboxes))
          restricted.instance_variable_set(:@search_criteria, merge_criteria(criteria))
          if remaining
            Operator::Restrict.new(type, restricted, remaining)
          else
            restricted
          end
        elsif remaining
          Operator::Restrict.new(type, self, remaining)
        else
          super
        end
      end

      def _project(type, attrlist)
        source = attrlist.include?(:body_text) ? self : without_body_fetch
        Operator::Project.new(type, source, attrlist)
      end

      def _allbut(type, butlist)
        source = butlist.include?(:body_text) ? without_body_fetch : self
        Operator::Allbut.new(type, source, butlist)
      end


    private

      def without_body_fetch
        dup.tap { |r| r.instance_variable_set(:@fetch_body, false) }
      end

      def merge_mailboxes(new_mailboxes)
        return @mailboxes unless new_mailboxes
        if @mailboxes
          @mailboxes & new_mailboxes
        else
          new_mailboxes
        end
      end

      def merge_criteria(new_criteria)
        return @search_criteria unless new_criteria
        if @search_criteria
          @search_criteria + new_criteria
        else
          new_criteria
        end
      end

      # Recombines the original predicate when criteria can't be pushed.
      # We need to return the full predicate since criteria was split out.
      def combine_remaining(remaining, criteria, original_predicate)
        original_predicate
      end

    end # class Relation
  end # module Imap
end # module Bmg
