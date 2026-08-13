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
    # Provider-specific intersect push-down (e.g. Gmail):
    #   restrict(Predicate.intersect(:labels, ["x"]))  => ["X-GM-LABELS", "x"]
    #
    # ## Limits
    #
    # - OR predicates are never pushed down (IMAP OR has different semantics)
    # - NOT predicates are never pushed down
    # - Predicates involving two identifiers (e.g. :from == :to) are not pushed
    # - in(...) predicates are not pushed (could be supported in the future)
    # - Date equality is not pushed (IMAP has ON but semantic mismatch with DateTime)
    # - eq on array attributes (e.g. :labels) is not pushed (exact match
    #   can't be expressed in IMAP SEARCH)
    # - intersect with multiple values is not pushed (IMAP SEARCH terms are
    #   ANDed, but intersect means "any overlap" which is OR)
    # - Unknown attributes are not pushed
    # - Anything that can't be pushed ends up in the `remaining` predicate,
    #   which bmg evaluates in-memory as usual.
    #
    class PredicateTranslator

      # IMAP SEARCH key for attributes supporting equality push-down
      CORE_EQ_ATTRS = {
        subject: "SUBJECT",
        from:    "FROM",
        to:      "TO",
        cc:      "CC",
        uid:     "UID",
      }.freeze

      # Attributes supporting date comparison push-down
      DATE_ATTRS = Set[:date].freeze

      # @param provider [Provider, nil] optional provider for extra search attrs
      def initialize(provider = nil)
        @eq_attrs = if provider
          CORE_EQ_ATTRS.merge(provider.search_attrs)
        else
          CORE_EQ_ATTRS
        end
        @intersect_attrs = provider ? provider.intersect_attrs : {}
      end

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
            tokens, keep = translate_attr_predicate(attr, attr_pred)
            if tokens
              criteria.concat(tokens)
              remaining_parts << attr_pred if keep
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
      # Returns [tokens, keep_as_remaining]:
      #   - tokens: array of IMAP SEARCH tokens, or nil if not translatable
      #   - keep_as_remaining: if true, the predicate is a pre-filter only
      #     and must also be evaluated in-memory for exact semantics
      def translate_attr_predicate(attr, predicate)
        sexpr = predicate.sexpr

        # eq on an intersect attr: push as pre-filter, keep for exact match
        if sexpr.first == :eq && @intersect_attrs[attr]
          tokens = translate_eq_as_prefilter(attr, sexpr)
          return [tokens, true] if tokens
        end

        [translate_sexpr(attr, sexpr), false]
      end

      def translate_sexpr(attr, sexpr)
        case sexpr.first
        when :eq
          translate_eq(attr, sexpr)
        when :intersect
          translate_intersect(attr, sexpr)
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
        imap_key = @eq_attrs[attr]
        return nil unless imap_key

        value = extract_literal(sexpr)
        return nil unless value

        [imap_key, value.to_s]
      end

      # Translates eq(:attr, [...]) on an intersect attr as a pre-filter.
      # Generates one IMAP SEARCH pair per array element (ANDed server-side).
      # This narrows results but doesn't enforce exact match — the caller
      # must also keep the predicate for in-memory evaluation.
      #
      # eq(:labels, ["A", "B"]) => ["X-GM-LABELS", "A", "X-GM-LABELS", "B"]
      # eq(:labels, ["A"])      => ["X-GM-LABELS", "A"]
      def translate_eq_as_prefilter(attr, sexpr)
        imap_key = @intersect_attrs[attr]
        return nil unless imap_key

        value = extract_literal(sexpr)
        return nil unless value.is_a?(Array) && !value.empty?

        value.flat_map { |v| [imap_key, v.to_s] }
      end

      # Translates intersect(:attr, ["val"]) for array attributes.
      # Only pushes down single-value intersects, because IMAP SEARCH
      # terms are ANDed, while intersect means "any overlap" (OR).
      #
      # Single value:  intersect(:labels, ["Projects"])
      #   => ["X-GM-LABELS", "Projects"]
      #
      # Multiple values: intersect(:labels, ["A", "B"])
      #   => nil (can't express OR in IMAP SEARCH, falls to in-memory)
      def translate_intersect(attr, sexpr)
        imap_key = @intersect_attrs[attr]
        return nil unless imap_key

        values = extract_literal(sexpr)
        return nil unless values.is_a?(Array) && values.size == 1

        [imap_key, values.first.to_s]
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
