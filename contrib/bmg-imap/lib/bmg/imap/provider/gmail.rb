module Bmg
  module Imap
    class Provider
      #
      # Gmail provider. Detected via X-GM-EXT-1 capability.
      #
      # Maps:
      #   :labels => X-GM-LABELS
      #
      class Gmail < Provider

        def extra_fetch_attrs
          ["X-GM-LABELS"]
        end

        def parse_extra(item)
          {
            labels: item.attr["X-GM-LABELS"] || [],
          }
        end

        def name
          "gmail"
        end

      end # class Gmail

      register ->(caps) { caps.include?("X-GM-EXT-1") }, Gmail

    end # class Provider
  end # module Imap
end # module Bmg
