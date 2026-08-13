module Bmg
  module Imap
    #
    # A Connection-compatible class that reads emails from mbox files
    # instead of connecting to an IMAP server.
    #
    # Supports two modes:
    # - Single file:  MboxConnection.new(path: "mail.mbox")
    # - Directory:    MboxConnection.new(path: "Maildir/")
    #   Each .mbox file in the directory becomes a mailbox.
    #
    # Implements the same interface as Connection:
    # - each_email(mailboxes, search_criteria, &bl)
    # - list_mailbox_names
    #
    class MboxConnection

      MBOX_FROM_LINE = /\AFrom\s+\S+/.freeze

      def initialize(options)
        @path = options[:path] || raise(Bmg::Error, "Mbox :path is required")
        @path = File.expand_path(@path)
      end

      def each_email(mailboxes = nil, search_criteria = nil, fetch_body: true, &bl)
        return to_enum(:each_email, mailboxes, search_criteria, fetch_body: fetch_body) unless block_given?

        target = mailboxes || list_mailbox_names
        target.each do |mbox_name|
          each_mbox_email(mbox_name, &bl)
        end
      end

      def list_mailbox_names
        if File.directory?(@path)
          Dir[File.join(@path, "*.mbox")].sort.map do |f|
            File.basename(f, ".mbox")
          end
        else
          [File.basename(@path, ".mbox")]
        end
      end

      def supports_search_criteria?
        false
      end

    private

      def each_mbox_email(mbox_name, &bl)
        file = mbox_file_for(mbox_name)
        return unless file && File.exist?(file)

        uid = 0
        split_mbox(file) do |raw_message|
          uid += 1
          tuple = parse_message(raw_message, mbox_name, uid)
          bl.call(tuple)
        end
      end

      def mbox_file_for(name)
        if File.directory?(@path)
          File.join(@path, "#{name}.mbox")
        elsif name == File.basename(@path, ".mbox")
          @path
        else
          nil
        end
      end

      # Splits an mbox file into individual raw message strings.
      # The mbox format separates messages with lines starting with "From ".
      def split_mbox(file)
        current = nil
        File.foreach(file) do |line|
          if line.match?(MBOX_FROM_LINE)
            yield current if current
            current = ""
          else
            current << line if current
          end
        end
        yield current if current
      end

      def parse_message(raw, mbox_name, uid)
        msg = Mail.read_from_string(raw)
        {
          uid:         uid,
          mailbox:     mbox_name,
          date:        msg.date ? msg.date.to_datetime : nil,
          subject:     msg.subject,
          from:        format_address_list(msg[:from]),
          to:          format_address_list(msg[:to]),
          cc:          format_address_list(msg[:cc]),
          bcc:         format_address_list(msg[:bcc]),
          reply_to:    format_address_list(msg[:reply_to]),
          in_reply_to: msg.in_reply_to,
          message_id:  msg.message_id ? "<#{msg.message_id}>" : nil,
          labels:      [],
          flags:       extract_flags(msg),
          size:        raw.bytesize,
          body_text:   extract_body_text(msg),
          raw:         raw,
        }
      end

      def format_address_list(field)
        return [] unless field
        formatted = field.formatted rescue nil
        return [] unless formatted && !formatted.empty?
        formatted
      end

      def extract_flags(msg)
        flags = []
        status = msg.header["Status"]&.value
        if status
          flags << :Seen if status.include?("R")
          flags << :Answered if status.include?("A")
        end
        x_status = msg.header["X-Status"]&.value
        if x_status
          flags << :Flagged if x_status.include?("F")
          flags << :Deleted if x_status.include?("D")
        end
        flags
      end

      def extract_body_text(msg)
        if msg.multipart?
          part = msg.text_part
          part ? part.decoded : nil
        else
          msg.decoded rescue msg.body.to_s
        end
      end

    end # class MboxConnection
  end # module Imap
end # module Bmg
