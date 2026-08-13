module Bmg
  module Imap
    class Provider
      #
      # Gmail provider. Detected via X-GM-EXT-1 capability,
      # or inferred from imap.gmail.com / imap.googlemail.com hosts.
      #
      # Maps:
      #   :labels => X-GM-LABELS (fetch + intersect search)
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

        def intersect_attrs
          { labels: "X-GM-LABELS" }
        end

        def name
          "gmail"
        end

      end # class Gmail

      register      ->(caps) { caps.include?("X-GM-EXT-1") }, Gmail
      register_host ->(host) { host.include?("gmail.com") || host.include?("googlemail.com") }, Gmail

    end # class Provider
  end # module Imap
end # module Bmg
