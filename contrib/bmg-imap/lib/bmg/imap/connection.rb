require 'net/imap'

module Bmg
  module Imap
    class Connection

      DEFAULT_OPTIONS = {
        batch_size: 100,
        limit: nil,
      }.freeze

      def initialize(options)
        @options = DEFAULT_OPTIONS.merge(options)
        @logger = @options[:logger]
        @imap = nil
        @provider = nil
        @selected_mailbox = nil
      end

      def each_email(mailboxes = nil, search_criteria = nil, fetch_body: true, &bl)
        return to_enum(:each_email, mailboxes, search_criteria, fetch_body: fetch_body) unless block_given?

        target_mailboxes = mailboxes || list_mailbox_names
        log("MAILBOXES #{target_mailboxes.inspect}")
        remaining = @options[:limit]
        target_mailboxes.each do |mbox|
          remaining = fetch_mailbox_emails(mbox, search_criteria, fetch_body, remaining, &bl)
          break if remaining == 0
        end
      end

      # Searches for UIDs matching criteria in the given mailboxes.
      # Returns a Hash { mailbox => [uid, ...] }.
      def search_uids(mailboxes, search_criteria)
        result = {}
        target_mailboxes = mailboxes || list_mailbox_names
        target_mailboxes.each do |mbox|
          select_mailbox(mbox)
          criteria = search_criteria || ["ALL"]
          uids = timed("UID SEARCH #{criteria.inspect}") do
            imap.uid_search(criteria)
          end
          log("  => #{uids.size} UIDs")
          result[mbox] = uids unless uids.empty?
        end
        result
      end

      def delete_uids(mailbox, uids)
        return if uids.empty?
        select_mailbox(mailbox)
        batch_size = @options[:batch_size]
        uids.each_slice(batch_size) do |batch|
          timed("UID STORE #{batch.first}..#{batch.last} +FLAGS (\\Deleted)") do
            imap.uid_store(batch, "+FLAGS", [:Deleted])
          end
        end
        timed("EXPUNGE") do
          imap.expunge
        end
        @selected_mailbox = nil # mailbox state changed after expunge
      end

      def store_flags(mailbox, uids, flags)
        return if uids.empty?
        select_mailbox(mailbox)
        batch_size = @options[:batch_size]
        uids.each_slice(batch_size) do |batch|
          timed("UID STORE #{batch.first}..#{batch.last} FLAGS #{flags.inspect}") do
            imap.uid_store(batch, "FLAGS", flags)
          end
        end
      end

      def store_labels(mailbox, uids, labels)
        return if uids.empty?
        select_mailbox(mailbox)
        batch_size = @options[:batch_size]
        uids.each_slice(batch_size) do |batch|
          timed("UID STORE #{batch.first}..#{batch.last} X-GM-LABELS #{labels.inspect}") do
            imap.uid_store(batch, "X-GM-LABELS", labels)
          end
        end
      end

      def move_uids(source_mailbox, uids, target_mailbox)
        return if uids.empty?
        select_mailbox(source_mailbox)
        batch_size = @options[:batch_size]
        if supports_move?
          uids.each_slice(batch_size) do |batch|
            timed("UID MOVE #{batch.first}..#{batch.last} #{target_mailbox}") do
              imap.uid_move(batch, target_mailbox)
            end
          end
        else
          uids.each_slice(batch_size) do |batch|
            timed("UID COPY #{batch.first}..#{batch.last} #{target_mailbox}") do
              imap.uid_copy(batch, target_mailbox)
            end
            timed("UID STORE #{batch.first}..#{batch.last} +FLAGS (\\Deleted)") do
              imap.uid_store(batch, "+FLAGS", [:Deleted])
            end
          end
          timed("EXPUNGE") do
            imap.expunge
          end
        end
        @selected_mailbox = nil
      end

      def list_mailbox_names
        (imap.list("", "*") || [])
          .reject { |mbox| mbox.attr.include?(:Noselect) }
          .map(&:name)
      end

      def close
        return unless @imap
        @imap.logout rescue nil
        @imap.disconnect rescue nil
        log("DISCONNECT")
        @imap = nil
        @selected_mailbox = nil
      end

      def supports_search_criteria?
        true
      end

    private

      # Returns a persistent IMAP connection, lazily initialized.
      # Reconnects transparently if the connection was lost.
      def imap
        return @imap if @imap && !@imap.disconnected?

        close if @imap # clean up stale connection
        @selected_mailbox = nil

        @imap = timed("CONNECT #{host}:#{port} (ssl: #{ssl?})") do
          Net::IMAP.new(host, port: port, ssl: ssl?)
        end
        timed("LOGIN #{username}") do
          @imap.login(username, password)
        end
        @provider = detect_provider(@imap)
        log("PROVIDER #{@provider.name}")
        @imap
      end

      def detect_provider(imap)
        capabilities = imap.responses("CAPABILITY", &:flatten) rescue imap.capability
        Provider.detect(capabilities)
      end

      def provider
        @provider || Provider::Default.new
      end

      def supports_move?
        @supports_move ||= begin
          caps = imap.responses("CAPABILITY", &:flatten) rescue imap.capability
          caps.any? { |c| c.to_s.upcase == "MOVE" }
        end
      end

      def select_mailbox(mailbox)
        return if @selected_mailbox == mailbox
        timed("SELECT #{mailbox}") do
          imap.select(mailbox)
        end
        @selected_mailbox = mailbox
      end

      # Returns the remaining limit (nil = unlimited, 0 = stop)
      def fetch_mailbox_emails(mailbox, search_criteria, fetch_body, remaining, &bl)
        select_mailbox(mailbox)
        criteria = search_criteria || ["ALL"]
        uids = timed("UID SEARCH #{criteria.inspect}") do
          imap.uid_search(criteria)
        end
        log("  => #{uids.size} UIDs")
        return remaining if uids.empty?

        uids = uids.first(remaining) if remaining
        fetch_items = build_fetch_items(fetch_body)
        log("  FETCH items: #{fetch_items.join(', ')}")

        batch_size = @options[:batch_size]
        fetched = 0
        uids.each_slice(batch_size) do |uid_batch|
          tuples = timed("UID FETCH #{uid_batch.first}..#{uid_batch.last} (#{uid_batch.size} msgs)") do
            fetch_batch(uid_batch, mailbox, fetch_body, fetch_items)
          end
          tuples.each do |tuple|
            fetched += 1
            bl.call(tuple)
          end
        end
        log("  => #{fetched} emails yielded from #{mailbox}")
        remaining ? remaining - fetched : nil
      end

      def build_fetch_items(fetch_body)
        items = ["UID", "ENVELOPE", "FLAGS", "RFC822.SIZE"]
        # Fetch the full RFC822 message rather than just BODY[TEXT] so we
        # can hand it to Mail and extract a decoded text/plain body — for
        # multipart messages BODY[TEXT] returns the raw multipart structure
        # (boundaries, part headers, un-decoded quoted-printable). Headers
        # are also fetched via ENVELOPE, so we accept a small overlap here.
        items << "BODY.PEEK[]" if fetch_body
        items.concat(provider.extra_fetch_attrs)
        items
      end

      def fetch_batch(uids, mailbox, fetch_body, fetch_items)
        data = imap.uid_fetch(uids, fetch_items)
        return [] unless data

        data.map do |item|
          parse_email(item, mailbox, fetch_body)
        end
      end

      def parse_email(item, mailbox, fetch_body)
        envelope = item.attr["ENVELOPE"]
        tuple = {
          uid:         item.attr["UID"],
          mailbox:     mailbox,
          date:        parse_date(envelope.date),
          subject:     decode_field(envelope.subject),
          from:        format_addresses(envelope.from),
          to:          format_addresses(envelope.to),
          cc:          format_addresses(envelope.cc),
          bcc:         format_addresses(envelope.bcc),
          reply_to:    format_addresses(envelope.reply_to),
          in_reply_to: envelope.in_reply_to,
          message_id:  envelope.message_id,
          flags:       item.attr["FLAGS"],
          size:        item.attr["RFC822.SIZE"],
          body_text:   fetch_body ? extract_body_text(item.attr["BODY[]"]) : nil,
        }
        tuple.merge!(provider.parse_extra(item))
        tuple
      end

      def parse_date(date_str)
        return nil unless date_str
        DateTime.parse(date_str) rescue nil
      end

      # Extracts a decoded plain text body from a full RFC822 message. For
      # multipart messages, picks the text/plain part and decodes any
      # transfer encoding (quoted-printable, base64); for single-part
      # messages, decodes the whole body. Mirrors MboxConnection's
      # behavior so both backends yield the same body_text shape.
      def extract_body_text(raw)
        return nil unless raw
        msg = Mail.read_from_string(raw)
        if msg.multipart?
          part = msg.text_part
          part ? part.decoded : nil
        else
          msg.decoded rescue msg.body.to_s
        end
      end

      def decode_field(value)
        return nil unless value
        Mail::Encodings.value_decode(value) rescue value
      end

      def format_addresses(addresses)
        return [] unless addresses
        addresses.map do |addr|
          if addr.name
            "#{decode_field(addr.name)} <#{addr.mailbox}@#{addr.host}>"
          else
            "#{addr.mailbox}@#{addr.host}"
          end
        end
      end

      def log(message)
        return unless @logger
        @logger.call("[bmg-imap] #{message}")
      end

      def timed(label)
        return yield unless @logger
        t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = yield
        dt = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round(1)
        log("#{label} (#{dt}ms)")
        result
      end

      def host
        @options[:host] || raise(Bmg::Error, "IMAP :host is required")
      end

      def port
        @options[:port] || (ssl? ? 993 : 143)
      end

      def ssl?
        @options.fetch(:ssl, true)
      end

      def username
        @options[:username] || raise(Bmg::Error, "IMAP :username is required")
      end

      def password
        @options[:password] || raise(Bmg::Error, "IMAP :password is required")
      end

    end # class Connection
  end # module Imap
end # module Bmg
