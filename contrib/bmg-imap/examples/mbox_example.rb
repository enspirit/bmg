#!/usr/bin/env ruby
#
# Example: Read a local mbox file as a Relation.
#
# Usage:
#   bundle exec ruby examples/mbox_example.rb path/to/file.mbox
#   bundle exec ruby examples/mbox_example.rb path/to/maildir/
#
require 'bmg'
require 'bmg/imap'

path = ARGV[0] || File.expand_path('../spec/fixtures/sample.mbox', __dir__)

# Build a relation backed by an mbox file (or directory of .mbox files)
connection = Bmg::Imap::MboxConnection.new(path: path)
emails = Bmg::Imap::Relation.new(
  Bmg::Imap::Relation::DEFAULT_TYPE,
  connection: connection,
)

# Show all mailboxes
puts "=== Mailboxes ==="
puts connection.list_mailbox_names.inspect
puts

# List all emails: date, from, subject
puts "=== All emails ==="
emails
  .project([:date, :from, :subject])
  .each do |tuple|
    puts "#{tuple[:date]}  #{tuple[:from]&.first}  #{tuple[:subject]}"
  end
puts

# Filter by sender
puts "=== Emails from Alice ==="
emails
  .restrict(Predicate.match(:from, /alice/i))
  .project([:date, :subject])
  .each do |tuple|
    puts "#{tuple[:date]}  #{tuple[:subject]}"
  end
puts

# Summarize: count emails per sender
puts "=== Email count per sender ==="
emails
  .extend(sender: ->(t) { t[:from]&.first || "(unknown)" })
  .summarize([:sender], :count => :count)
  .each do |tuple|
    puts "#{tuple[:sender]} :: #{tuple[:count]}"
  end
