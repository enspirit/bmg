module Bmg
  module Imap
    #
    # Providers map official bmg-imap attributes to provider-specific
    # IMAP extensions. Each provider declares:
    #
    # - extra_fetch_attrs: additional IMAP FETCH items to request
    # - parse_extra(item): extract official attributes from fetch response
    # - defaults: default values for official attributes (used when the
    #   provider doesn't support them)
    #
    # Detection is automatic: after LOGIN, the CAPABILITY response is
    # checked to select the right provider.
    #
    # ## Official extra attributes
    #
    # | Attribute  | Type            | Gmail (X-GM-EXT-1) | Default |
    # |------------|-----------------|---------------------|---------|
    # | :labels    | Array<String>   | X-GM-LABELS         | []      |
    #
    # Providers can also override strategy hooks — currently only
    # `delete_uids` (see Gmail's move-to-Trash override).
    #
    class Provider

      # Detects the provider from IMAP capabilities.
      #
      # @param capabilities [Array<String>] CAPABILITY response items
      # @return [Provider] the detected provider instance
      def self.detect(capabilities)
        caps = capabilities.map { |c| c.to_s.upcase }
        REGISTRY.each do |test, klass|
          return klass.new if test.call(caps)
        end
        Default.new
      end

      # Infers a provider from a hostname.
      # Returns nil if no provider matches.
      def self.infer_from_host(host)
        return nil unless host
        h = host.to_s.downcase
        HOST_REGISTRY.each do |test, klass|
          return klass.new if test.call(h)
        end
        nil
      end

      # Registry of provider detection rules (CAPABILITY-based), checked in order.
      REGISTRY = []

      # Registry of host-based inference rules, checked in order.
      HOST_REGISTRY = []

      def self.register(test, klass)
        REGISTRY << [test, klass]
      end

      def self.register_host(test, klass)
        HOST_REGISTRY << [test, klass]
      end

      # Extra IMAP FETCH attributes to request (e.g. ["X-GM-LABELS"])
      def extra_fetch_attrs
        []
      end

      # Parse provider-specific data from a fetch response item
      # into a hash of official attributes.
      #
      # @param item [Net::IMAP::FetchData] a single fetch response
      # @return [Hash] official attribute => value
      def parse_extra(item)
        defaults
      end

      # Default values for all official extra attributes.
      # Used as fallback when the provider doesn't support them.
      def defaults
        { labels: [] }
      end

      # Provider-specific IMAP SEARCH keys for equality push-down.
      # Maps official attribute name => IMAP SEARCH key string.
      def search_attrs
        {}
      end

      # Provider-specific IMAP SEARCH keys for intersect push-down.
      # Used for array attributes where the IMAP SEARCH key checks
      # membership (e.g. X-GM-LABELS "x" checks if label "x" is present).
      # Maps official attribute name => IMAP SEARCH key string.
      def intersect_attrs
        {}
      end

      # Deletion strategy. The default is the standard IMAP recipe —
      # STORE \Deleted on the message + EXPUNGE the mailbox. Providers
      # whose server ignores \Deleted (Gmail with Auto-Expunge off, ...)
      # should override to move the messages to a trash mailbox instead.
      def delete_uids(connection, mailbox, uids)
        connection.expunge_uids(mailbox, uids)
      end

      def name
        "default"
      end

    end # class Provider
  end # module Imap
end # module Bmg
require_relative 'provider/default'
require_relative 'provider/gmail'
