module Bmg
  module Imap
    class Relation
      include Bmg::Relation

      ATTRLIST = [
        :uid, :mailbox, :date, :subject,
        :from, :to, :cc, :bcc, :reply_to,
        :in_reply_to, :message_id,
        :labels, :flags, :size, :body_text, :raw,
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

      # Supported updating keys:
      #   flags:   [:Seen, :Flagged, ...]   — replace all flags
      #   labels:  ["Projects", ...]        — replace all labels (Gmail)
      #   mailbox: "Archive"                — move to another mailbox
      def update(updating, predicate = Predicate.tautology)
        validate_updating!(updating)
        uids_by_mailbox = resolve_uids(predicate)

        if updating.key?(:mailbox)
          target = updating[:mailbox]
          uids_by_mailbox.each do |mbox, uids|
            connection.move_uids(mbox, uids, target)
          end
        end

        if updating.key?(:flags)
          uids_by_mailbox.each do |mbox, uids|
            connection.store_flags(mbox, uids, updating[:flags])
          end
        end

        if updating.key?(:labels)
          uids_by_mailbox.each do |mbox, uids|
            connection.store_labels(mbox, uids, updating[:labels])
          end
        end

        self
      end

      def delete(predicate = Predicate.tautology)
        uids_by_mailbox = resolve_uids(predicate)
        uids_by_mailbox.each do |mbox, uids|
          connection.delete_uids(mbox, uids)
        end
        self
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

      # Body attributes derived from BODY.PEEK[]. If NONE of them is kept
      # by the caller, the fetch skips the message body entirely.
      BODY_ATTRS = [:body_text, :raw].freeze

      def _project(type, attrlist)
        source = (attrlist & BODY_ATTRS).empty? ? without_body_fetch : self
        Operator::Project.new(type, source, attrlist)
      end

      def _allbut(type, butlist)
        source = (BODY_ATTRS - butlist).empty? ? without_body_fetch : self
        Operator::Allbut.new(type, source, butlist)
      end


    private

      UPDATABLE_ATTRS = Set[:flags, :labels, :mailbox].freeze

      def validate_updating!(updating)
        unknown = updating.keys.reject { |k| UPDATABLE_ATTRS.include?(k) }
        unless unknown.empty?
          raise Bmg::Error, "Cannot update #{unknown.join(', ')} on IMAP emails. " \
            "Updatable attributes: #{UPDATABLE_ATTRS.to_a.join(', ')}"
        end
      end

      # Resolves the UIDs to act on, grouped by mailbox.
      # When predicate is tautology, uses the pushed-down mailboxes/criteria.
      # When predicate is given, fetches and filters in-memory to collect UIDs.
      # Returns Hash { mailbox => [uid, ...] }
      def resolve_uids(predicate)
        if predicate.tautology?
          connection.search_uids(@mailboxes, @search_criteria)
        else
          # Must fetch tuples and filter in-memory to find matching UIDs
          result = Hash.new { |h, k| h[k] = [] }
          each do |tuple|
            if predicate.evaluate(tuple)
              result[tuple[:mailbox]] << tuple[:uid]
            end
          end
          result
        end
      end

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
