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

      # Registry of provider detection rules, checked in order.
      # Each entry is [lambda(caps) -> bool, ProviderClass].
      REGISTRY = []

      def self.register(test, klass)
        REGISTRY << [test, klass]
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

      def name
        "default"
      end

    end # class Provider
  end # module Imap
end # module Bmg
require_relative 'provider/default'
require_relative 'provider/gmail'
