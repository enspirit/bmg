require 'rspec'
require 'bmg'
require 'bmg/imap'

module SpecHelpers

  def imap_options
    {
      host: "imap.example.com",
      username: "user@example.com",
      password: "secret",
      ssl: true,
      mailbox: "INBOX",
    }
  end

  def sample_emails
    [
      {
        uid: 1,
        mailbox: "INBOX",
        date: DateTime.new(2025, 1, 15, 10, 30),
        subject: "Hello World",
        from: ["alice@example.com"],
        to: ["bob@example.com"],
        cc: nil,
        reply_to: nil,
        message_id: "<msg1@example.com>",
        flags: [:Seen],
        size: 1234,
        body_text: "Hello!",
      },
      {
        uid: 2,
        mailbox: "INBOX",
        date: DateTime.new(2025, 1, 16, 14, 0),
        subject: "Re: Hello World",
        from: ["bob@example.com"],
        to: ["alice@example.com"],
        cc: nil,
        reply_to: nil,
        message_id: "<msg2@example.com>",
        flags: [],
        size: 2345,
        body_text: "Hi there!",
      },
    ]
  end

end

RSpec.configure do |c|
  c.include SpecHelpers
end
