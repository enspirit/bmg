require 'net/imap'

module Bmg
  module Imap
    class Connection

      def initialize(options)
        @options = options
        @logger = options[:logger]
        @imap = nil
        @provider = nil
        @selected_mailbox = nil
      end

      def each_email(mailboxes = nil, search_criteria = nil, fetch_body: true, &bl)
        return to_enum(:each_email, mailboxes, search_criteria, fetch_body: fetch_body) unless block_given?

        target_mailboxes = mailboxes || list_mailbox_names
        log("MAILBOXES #{target_mailboxes.inspect}")
        target_mailboxes.each do |mbox|
          fetch_mailbox_emails(mbox, search_criteria, fetch_body, &bl)
        end
      end

      def list_mailbox_names
        (imap.list("", "*") || []).map(&:name)
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

      def select_mailbox(mailbox)
        return if @selected_mailbox == mailbox
        timed("SELECT #{mailbox}") do
          imap.select(mailbox)
        end
        @selected_mailbox = mailbox
      end

      def fetch_mailbox_emails(mailbox, search_criteria, fetch_body, &bl)
        select_mailbox(mailbox)
        criteria = search_criteria || ["ALL"]
        uids = timed("UID SEARCH #{criteria.inspect}") do
          imap.uid_search(criteria)
        end
        log("  => #{uids.size} UIDs")
        return if uids.empty?

        fetch_items = build_fetch_items(fetch_body)
        log("  FETCH items: #{fetch_items.join(', ')}")

        fetched = 0
        uids.each_slice(100) do |uid_batch|
          tuples = timed("UID FETCH #{uid_batch.first}..#{uid_batch.last} (#{uid_batch.size} msgs)") do
            fetch_batch(uid_batch, mailbox, fetch_body, fetch_items)
          end
          tuples.each do |tuple|
            fetched += 1
            bl.call(tuple)
          end
        end
        log("  => #{fetched} emails yielded from #{mailbox}")
      end

      def build_fetch_items(fetch_body)
        items = ["UID", "ENVELOPE", "FLAGS", "RFC822.SIZE"]
        items << "BODY.PEEK[TEXT]" if fetch_body
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
          body_text:   fetch_body ? item.attr["BODY[TEXT]"] : nil,
        }
        tuple.merge!(provider.parse_extra(item))
        tuple
      end

      def parse_date(date_str)
        return nil unless date_str
        DateTime.parse(date_str) rescue nil
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
