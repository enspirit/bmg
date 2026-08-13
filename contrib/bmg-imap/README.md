# bmg-imap

A [bmg](https://github.com/enspirit/bmg) adapter that exposes IMAP mailboxes
as relations. Also supports reading local mbox files.

## Installation

```ruby
gem 'bmg-imap'
```

## Quick start

### IMAP

```ruby
require 'bmg'
require 'bmg/imap'

emails = Bmg::Imap::Relation.new(
  Bmg::Imap::Relation::DEFAULT_TYPE,
  host:     "imap.gmail.com",
  username: "you@gmail.com",
  password: "your-app-password",
  ssl:      true,
)

# Recent inbox emails
emails
  .restrict(mailbox: "INBOX")
  .restrict(Predicate.gte(:date, Date.today - 7))
  .project([:date, :from, :subject])
  .each { |t| puts t.inspect }
```

### Update and delete

```ruby
# Mark emails as read
emails.restrict(mailbox: "INBOX", uid: 123).update(flags: [:Seen])

# Add labels (Gmail)
emails.restrict(mailbox: "INBOX", uid: 123).update(labels: ["Projects", "Important"])

# Move to another mailbox
emails.restrict(mailbox: "INBOX", uid: 123).update(mailbox: "Archive")

# Multiple updates at once
emails.restrict(mailbox: "INBOX", uid: 123).update(flags: [:Seen], labels: ["Done"])

# Delete matching emails
emails.restrict(mailbox: "INBOX", from: "spam@x.com").delete
```

Updatable attributes:

| Attribute  | IMAP command | Notes |
|------------|-------------|-------|
| `:flags`   | `STORE FLAGS` | **Replaces** all flags with the given set |
| `:labels`  | `STORE X-GM-LABELS` | Gmail only. **Replaces** all labels — existing labels not in the array are removed |
| `:mailbox` | `MOVE` or `COPY`+`DELETE` | Uses MOVE extension when available |

All other attributes (`:subject`, `:from`, `:date`, etc.) are read-only.
Update uses **replace semantics** (like SQL `SET`), not add/remove.

### Mbox files

```ruby
connection = Bmg::Imap::MboxConnection.new(path: "archive.mbox")
emails = Bmg::Imap::Relation.new(
  Bmg::Imap::Relation::DEFAULT_TYPE,
  connection: connection,
)

emails.project([:date, :from, :subject]).each { |t| puts t.inspect }
```

Point to a directory of `.mbox` files to get multiple mailboxes:

```ruby
connection = Bmg::Imap::MboxConnection.new(path: "mail/")
# Each .mbox file becomes a mailbox name
connection.list_mailbox_names  # => ["inbox", "sent", ...]
```

## Tuple attributes

Every email is represented as a tuple (Hash) with the following attributes:

| Attribute      | Type             | Description                                      |
|----------------|------------------|--------------------------------------------------|
| `:uid`         | Integer          | Unique message identifier (per mailbox)          |
| `:mailbox`     | String           | Mailbox name (e.g. `"INBOX"`, `"[Gmail]/Sent Mail"`) |
| `:date`        | DateTime or nil  | Date from the message header (sender's date)     |
| `:subject`     | String or nil    | Subject line                                     |
| `:from`        | Array\<String\>  | Sender addresses (e.g. `["Alice <alice@x.com>"]`) |
| `:to`          | Array\<String\>  | Recipient addresses                              |
| `:cc`          | Array\<String\>  | CC addresses (empty array if none)               |
| `:bcc`         | Array\<String\>  | BCC addresses (empty array if none)              |
| `:reply_to`    | Array\<String\>  | Reply-To addresses                               |
| `:in_reply_to` | String or nil    | Message-ID of the parent message (for threading) |
| `:message_id`  | String or nil    | Message-ID (e.g. `"<abc@example.com>"`)          |
| `:labels`      | Array\<String\>  | Provider-specific labels (see below)             |
| `:flags`       | Array\<Symbol\>  | IMAP flags (e.g. `[:Seen, :Flagged]`)            |
| `:size`        | Integer          | Message size in bytes                            |
| `:body_text`   | String or nil    | Plain text body                                  |

Notes:
- Address fields (`:from`, `:to`, `:cc`, `:bcc`, `:reply_to`) are always
  arrays, never nil. An empty array means no addresses.
- `:body_text` is always fetched by default (the relation is complete).
  When you `project` or `allbut` it away, the IMAP backend automatically
  skips `BODY.PEEK[TEXT]` and only fetches envelope metadata, which is
  significantly faster. See [Performance](#performance-considerations).
- `:labels` is populated via provider-specific extensions when available
  (see [Providers](#providers)). Returns `[]` on servers with no label support.
- `:uid` is unique within a mailbox but not across mailboxes.

## Predicate push-down

When using the IMAP backend, `restrict` predicates are translated to
IMAP SEARCH commands when possible, avoiding downloading all emails.

### What gets pushed down

| Predicate                            | IMAP SEARCH           |
|--------------------------------------|-----------------------|
| `restrict(mailbox: "INBOX")`         | Only opens that mailbox (not a SEARCH criterion) |
| `restrict(from: "alice@x.com")`      | `FROM "alice@x.com"`  |
| `restrict(to: "bob@x.com")`          | `TO "bob@x.com"`      |
| `restrict(cc: "carol@x.com")`        | `CC "carol@x.com"`    |
| `restrict(subject: "Hello")`         | `SUBJECT "Hello"`     |
| `restrict(uid: 42)`                  | `UID "42"`            |
| `restrict(Predicate.gte(:date, d))`  | `SINCE "1-Jan-2025"`  |
| `restrict(Predicate.gt(:date, d))`   | `SINCE "1-Jan-2025"`  |
| `restrict(Predicate.lt(:date, d))`   | `BEFORE "1-Jan-2025"` |
| `restrict(Predicate.lte(:date, d))`  | `BEFORE "1-Jan-2025"` |

Multiple pushable predicates are combined. For example:

```ruby
emails
  .restrict(mailbox: "INBOX", from: "alice@x.com")
  .restrict(Predicate.gte(:date, Date.today - 30))
```

Opens only `INBOX` and issues `UID SEARCH FROM "alice@x.com" SINCE "14-Jul-2025"`.

### Labels push-down (provider-specific)

Since `:labels` is an `Array<String>`, two predicates make sense:

| Predicate | Meaning | IMAP push-down (Gmail) | In-memory |
|---|---|---|---|
| `Predicate.intersect(:labels, ["A"])` | Has label A (among others) | `X-GM-LABELS "A"` | no |
| `Predicate.intersect(:labels, ["A","B"])` | Has A or B | none | yes |
| `Predicate.eq(:labels, ["A"])` | Has exactly [A] | `X-GM-LABELS "A"` (pre-filter) | + exact check |
| `Predicate.eq(:labels, ["A","B"])` | Has exactly [A, B] | `X-GM-LABELS "A" X-GM-LABELS "B"` (pre-filter) | + exact check |

`eq` pre-filtering is safe: IMAP returns a superset (all emails that have
those labels, possibly more), then bmg enforces the exact match in-memory.

Multi-value `intersect` cannot be pre-filtered because IMAP ANDs search
terms, while intersect needs OR semantics.

On servers without label support, all label predicates are evaluated
in-memory.

### What does NOT get pushed down

These predicates are evaluated in-memory by bmg after fetching:

- **OR** predicates (`|`)
- **NOT** predicates (`!`)
- **Date equality** (`restrict(date: d)`) -- IMAP's `ON` has day-granularity
  which doesn't match DateTime equality
- **`in(...)` predicates**
- **Multi-value `intersect`** on labels (needs OR, IMAP only ANDs)
- **Predicates on non-searchable attributes** (`:flags`, `:size`,
  `:in_reply_to`, `:message_id`, `:body_text`, `:bcc`, `:reply_to`)
- **Two-identifier comparisons** (e.g. `:from == :to`)

This is always safe: non-pushed predicates simply fall through to bmg's
standard in-memory filtering.

### Mbox backend

The mbox backend does not support IMAP SEARCH. All predicates (except
`:mailbox`) are evaluated in-memory. The `:mailbox` restriction still
works: it selects which `.mbox` file(s) to read.

## IMAP protocol tracing

Pass a `:logger` to see every IMAP command and its timing:

```ruby
emails = Bmg::Imap::Relation.new(
  Bmg::Imap::Relation::DEFAULT_TYPE,
  host: "imap.gmail.com",
  username: "you@gmail.com",
  password: "secret",
  logger: ->(msg) { $stderr.puts msg },
)
```

Output:

```
[bmg-imap] CONNECT imap.gmail.com:993 (ssl: true) (165.0ms)
[bmg-imap] LOGIN you@gmail.com (361.7ms)
[bmg-imap] MAILBOXES ["INBOX"]
[bmg-imap] SELECT INBOX (2256.7ms)
[bmg-imap] UID SEARCH ["SINCE", "10-Aug-2025"] (614.9ms)
[bmg-imap]   => 139 UIDs
[bmg-imap] UID FETCH 558893..559077 (100 msgs) (412.8ms)
[bmg-imap] UID FETCH 559087..559155 (39 msgs) (207.7ms)
[bmg-imap]   => 139 emails yielded from INBOX
[bmg-imap] DISCONNECT
```

## Connection options

| Option       | Default | Description                              |
|--------------|---------|------------------------------------------|
| `:host`      | required | IMAP server hostname                    |
| `:username`  | required | Login username                          |
| `:password`  | required | Login password (use app passwords for Gmail) |
| `:ssl`       | `true`   | Use SSL/TLS                             |
| `:port`      | 993 (ssl) / 143 | IMAP port                        |
| `:timezone`  | `nil`    | Timezone offset for date formatting (e.g. `"+02:00"`) |
| `:limit`     | `nil`    | Max total emails to fetch (nil = unlimited) |
| `:batch_size`| `100`    | Number of emails per IMAP FETCH round-trip |
| `:logger`    | `nil`    | Lambda for protocol tracing             |
| `:connection`| `nil`    | Provide your own connection (e.g. `MboxConnection`) |

## Gmail notes

- Enable IMAP in Gmail settings
- Use an [App Password](https://myaccount.google.com/apppasswords)
  (requires 2-Step Verification)
- Gmail mailbox names use the `[Gmail]/` prefix for special folders:
  `[Gmail]/Sent Mail`, `[Gmail]/All Mail`, `[Gmail]/Drafts`, etc.

## Providers

bmg-imap auto-detects the email provider from the IMAP CAPABILITY response
and uses provider-specific extensions to populate official attributes.

| Provider | Detection           | `:labels`                  |
|----------|---------------------|----------------------------|
| Gmail    | `X-GM-EXT-1`        | `X-GM-LABELS` (e.g. `["Projects", "\\Important"]`) |
| Default  | (fallback)          | `[]`                       |

Provider detection is logged when tracing is enabled:

```
[bmg-imap] PROVIDER gmail
```

Adding a new provider (e.g. Microsoft 365) only requires creating a new
`Provider` subclass that declares which IMAP FETCH items to request and
how to parse them into official attributes. See `lib/bmg/imap/provider/`
for examples.

## Performance considerations

- **Body text fetch is automatic but optimizable.** By default, `body_text`
  is fetched (via `BODY.PEEK[TEXT]`), making the relation complete. This can
  be slow for large result sets. When you use `project` or `allbut` to
  exclude `:body_text`, the IMAP fetch automatically skips body download
  and only requests envelope metadata — which is much faster:

  ```ruby
  # Slow: fetches body text for every email
  emails.restrict(mailbox: "INBOX").to_a

  # Fast: only fetches envelope metadata
  emails.restrict(mailbox: "INBOX").project([:date, :from, :subject]).to_a

  # Also fast: allbut body_text
  emails.restrict(mailbox: "INBOX").allbut([:body_text]).to_a
  ```

- **Persistent connection.** The IMAP connection is opened lazily on
  first use and kept open across queries. Subsequent calls reuse the
  same session, avoiding repeated CONNECT/LOGIN overhead. The currently
  selected mailbox is tracked; querying the same mailbox twice skips the
  SELECT command. Call `connection.close` when done, or let GC clean up.
- **SELECT** can be slow on large mailboxes (server-side cost, nothing
  the client can do about it). But it's only issued once per mailbox
  thanks to connection reuse.
- **`page()` requires all matching emails** to be fetched before sorting
  and slicing. For large result sets, restrict with date ranges or other
  criteria first.

## Examples

See the `examples/` directory:

- `examples/imap_example.rb` -- IMAP access using environment variables
- `examples/mbox_example.rb` -- reading a local mbox file
