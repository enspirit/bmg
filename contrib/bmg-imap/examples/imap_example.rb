#!/usr/bin/env ruby
#
# Example: Access an IMAP mailbox as a Relation.
#
# Set the following environment variables before running:
#
#   export BMG_IMAP_HOST=imap.gmail.com
#   export BMG_IMAP_USERNAME=you@gmail.com
#   export BMG_IMAP_PASSWORD=your-app-password
#
# Then: bundle exec ruby examples/imap_example.rb
#
require 'bmg'
require 'bmg/imap'
require 'json'

# Build the relation from env credentials
# Pass logger: to trace IMAP protocol calls on stderr
emails = Bmg::Imap::Relation.new(
  Bmg::Imap::Relation::DEFAULT_TYPE,
  host:     ENV.fetch("BMG_IMAP_HOST"),
  username: ENV.fetch("BMG_IMAP_USERNAME"),
  password: ENV.fetch("BMG_IMAP_PASSWORD"),
  ssl:      true,
  logger:   ->(msg) { $stderr.puts msg },
)

# List recent emails (last 30 days)
since = Date.today - 30
recent = emails
  .restrict(mailbox: "[Gmail]/All Mail")
  .restrict(Predicate.gte(:date, since))
  .restrict(Predicate.intersect(:labels, ["dmarc"]))
  .allbut([:body_text])
  .page([[:date,:desc]], 1, page_size: 20)

puts "=== Recent emails (last 30 days) ==="
# recent.each do |tuple|
#   puts "#{tuple[:date]}  #{tuple[:from]&.first}  #{tuple[:subject]}"
# end
puts JSON.pretty_generate(recent)
puts

# Count emails per mailbox
# puts "=== Email count ==="
# puts "Total: #{emails.restrict(mailbox: "[Gmail]/All Mail").count}"
