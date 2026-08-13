module Bmg
  module Imap
    #
    # Translates a Predicate into three parts:
    # - an array of mailbox names to restrict to (or nil for all)
    # - an IMAP SEARCH criteria array (or nil for ALL)
    # - a remaining Predicate for what couldn't be pushed down (or nil)
    #
    # Uses Predicate's `and_split` and `attr_split` to cleanly decompose
    # the predicate rather than walking the internal sexpr representation.
    #
    # ## Supported push-downs
    #
    # Mailbox (handled separately, not an IMAP SEARCH criterion):
    #   restrict(mailbox: "INBOX")  =>  mailboxes: ["INBOX"]
    #
    # Equality on string-searched fields:
    #   restrict(from: "x")    => ["FROM", "x"]
    #   restrict(to: "x")      => ["TO", "x"]
    #   restrict(cc: "x")      => ["CC", "x"]
    #   restrict(subject: "x") => ["SUBJECT", "x"]
    #
    # Equality on UID:
    #   restrict(uid: 42)      => ["UID", "42"]
    #
    # Date comparisons:
    #   restrict(Predicate.gt(:date, d))  => ["SINCE", "d"]
    #   restrict(Predicate.gte(:date, d)) => ["SINCE", "d"]
    #   restrict(Predicate.lt(:date, d))  => ["BEFORE", "d"]
    #   restrict(Predicate.lte(:date, d)) => ["BEFORE", "d"]
    #
    # ## Limits
    #
    # - OR predicates are never pushed down (IMAP OR has different semantics)
    # - NOT predicates are never pushed down
    # - Predicates involving two identifiers (e.g. :from == :to) are not pushed
    # - in(...) predicates are not pushed (could be supported in the future)
    # - Date equality is not pushed (IMAP has ON but semantic mismatch with DateTime)
    # - Unknown attributes are not pushed
    # - Anything that can't be pushed ends up in the `remaining` predicate,
    #   which bmg evaluates in-memory as usual.
    #
    class PredicateTranslator

      # IMAP SEARCH key for attributes supporting equality push-down
      EQ_ATTRS = {
        subject: "SUBJECT",
        from:    "FROM",
        to:      "TO",
        cc:      "CC",
        uid:     "UID",
      }.freeze

      # Attributes supporting date comparison push-down
      DATE_ATTRS = Set[:date].freeze

      # All attributes that can be pushed down (excluding mailbox)
      PUSHABLE_ATTRS = (EQ_ATTRS.keys + DATE_ATTRS.to_a).freeze

      # Translates a Predicate into [mailboxes, criteria, remaining].
      #
      # @param predicate [Predicate] the predicate to translate
      # @return [Array] [mailboxes, criteria, remaining]
      #   - mailboxes: Array of mailbox name strings, or nil for all
      #   - criteria: Array of IMAP SEARCH criteria tokens, or nil for ALL
      #   - remaining: a Predicate for what couldn't be pushed, or nil
      def call(predicate)
        # 1. Split out the mailbox part using and_split
        mailbox_pred, rest = predicate.and_split([:mailbox])

        # 2. Extract mailbox value(s) from the mailbox predicate
        mailboxes = extract_mailboxes(mailbox_pred)

        # 3. If there's nothing left, we're done
        return [mailboxes, nil, nil] if rest.tautology?

        # 4. Split the remaining predicate by attribute
        criteria, remaining = translate_search(rest)

        [mailboxes, criteria, remaining]
      end

    private

      # Extracts mailbox names from a predicate that only involves :mailbox.
      # Returns nil if the predicate is a tautology (no mailbox restriction).
      def extract_mailboxes(pred)
        return nil if pred.tautology?

        h = pred.to_hash
        value = h[:mailbox]
        value ? [value.to_s] : nil
      rescue ArgumentError
        # Predicate is not a simple equality (e.g. OR, NOT, etc.)
        # Can't extract mailbox names — leave it for in-memory filtering
        nil
      end

      # Translates a predicate (that has no :mailbox refs) into IMAP criteria.
      # Uses attr_split to decompose by attribute, translating each part
      # independently.
      #
      # Returns [criteria_array_or_nil, remaining_predicate_or_nil]
      def translate_search(predicate)
        by_attr = predicate.attr_split
        criteria = []
        remaining_parts = []

        by_attr.each do |attr, attr_pred|
          if attr.nil?
            # Multi-attribute predicate — can't push down
            remaining_parts << attr_pred
          else
            translated = translate_attr_predicate(attr, attr_pred)
            if translated
              criteria.concat(translated)
            else
              remaining_parts << attr_pred
            end
          end
        end

        final_criteria = criteria.empty? ? nil : criteria
        final_remaining = combine_predicates(remaining_parts)
        [final_criteria, final_remaining]
      end

      # Translates a single-attribute predicate to IMAP criteria.
      # Returns an array of IMAP tokens, or nil if not translatable.
      def translate_attr_predicate(attr, predicate)
        sexpr = predicate.sexpr
        translate_sexpr(attr, sexpr)
      end

      def translate_sexpr(attr, sexpr)
        case sexpr.first
        when :eq
          translate_eq(attr, sexpr)
        when :and
          parts = sexpr[1..-1].map { |s| translate_sexpr(attr, s) }
          return nil if parts.any?(&:nil?)
          parts.inject(:+)
        when :gt, :gte
          translate_date_comp(attr, sexpr, "SINCE")
        when :lt, :lte
          translate_date_comp(attr, sexpr, "BEFORE")
        else
          nil
        end
      end

      def translate_eq(attr, sexpr)
        imap_key = EQ_ATTRS[attr]
        return nil unless imap_key

        value = extract_literal(sexpr)
        return nil unless value

        [imap_key, value.to_s]
      end

      def translate_date_comp(attr, sexpr, imap_op)
        return nil unless DATE_ATTRS.include?(attr)

        value = extract_literal(sexpr)
        return nil unless value

        date_str = value.respond_to?(:strftime) ? value.strftime("%-d-%b-%Y") : value.to_s
        [imap_op, date_str]
      end

      def extract_literal(sexpr)
        lit = sexpr.find { |s| s.is_a?(Array) && s.first == :literal }
        lit ? lit[1] : nil
      end

      def combine_predicates(preds)
        return nil if preds.empty?
        preds.inject(:&)
      end

    end # class PredicateTranslator
  end # module Imap
end # module Bmg
