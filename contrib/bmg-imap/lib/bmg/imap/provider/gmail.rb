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

        # Gmail interprets the \Deleted flag differently depending on the
        # user's Auto-Expunge setting; with the modern default (off),
        # STORE \Deleted + EXPUNGE is silently ignored on non-Trash
        # mailboxes. The Gmail-native way to delete is to move the
        # message to Trash — mirroring what clicking Delete in the UI
        # does. Messages already in Trash fall through to the standard
        # STORE + EXPUNGE recipe to actually purge them.
        def delete_uids(connection, mailbox, uids)
          trash = trash_mailbox(connection)
          if trash && mailbox != trash
            connection.move_uids(mailbox, uids, trash)
          else
            connection.expunge_uids(mailbox, uids)
          end
        end

        # Resolves Gmail's trash mailbox once per provider instance.
        # Prefers RFC 6154 SPECIAL-USE discovery (returns whatever the
        # server labels `\Trash`, so localized names like `[Gmail]/Bin`
        # work); falls back to well-known Gmail names when the extended
        # LIST is unavailable.
        def trash_mailbox(connection)
          return @trash_mailbox if defined?(@trash_mailbox)
          @trash_mailbox =
            connection.find_special_use_mailbox(:Trash) ||
            fallback_trash(connection)
        end

        def name
          "gmail"
        end

      private

        FALLBACK_TRASH = [
          "[Gmail]/Trash",
          "[Gmail]/Bin",
          "[Google Mail]/Trash",
          "[Google Mail]/Bin",
        ].freeze

        def fallback_trash(connection)
          names = connection.list_mailbox_names
          FALLBACK_TRASH.find { |n| names.include?(n) }
        end

      end # class Gmail

      register      ->(caps) { caps.include?("X-GM-EXT-1") }, Gmail
      register_host ->(host) { host.include?("gmail.com") || host.include?("googlemail.com") }, Gmail

    end # class Provider
  end # module Imap
end # module Bmg
