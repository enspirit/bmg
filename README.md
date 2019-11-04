# Bmg, a relational algebra (Alf's successor)!

Bmg is a relational algebra implemented as a ruby library. It implements the
[Relation as First-Class Citizen](http://www.try-alf.org/blog/2013-10-21-relations-as-first-class-citizen)
paradigm contributed with Alf a few years ago.

Like Alf, Bmg can be used to query relations in memory, from various files,
SQL databases, and any data sources that can be seen as serving relations.
Cross data-sources joins are supported, as with Alf.

Unlike Alf, Bmg does not make any core ruby extension and exposes the
object-oriented syntax only (not Alf's functional one). Bmg implementation is
also much simpler, and make its easier to implement user-defined relations.

## Example

```
require 'bmg'
require 'json'

suppliers = Bmg::Relation.new([
  { sid: "S1", name: "Smith", status: 20, city: "London" },
  { sid: "S2", name: "Jones", status: 10, city: "Paris"  },
  { sid: "S3", name: "Blake", status: 30, city: "Paris"  },
  { sid: "S4", name: "Clark", status: 20, city: "London" },
  { sid: "S5", name: "Adams", status: 30, city: "Athens" }
])

by_city = suppliers
  .restrict(Predicate.neq(status: 30))
  .extend(upname: ->(t){ t[:name].upcase })
  .group([:sid, :name, :status], :suppliers_in)

puts JSON.pretty_generate(by_city)
```

## Connecting to a SQL database

Bmg requires `sequel >= 3.0` to connect to SQL databases.

```
require 'sqlite3'
require 'bmg'
require 'bmg/sequel'

DB = Sequel.connect("sqlite://suppliers-and-parts.db")

suppliers = Bmg.sequel(:suppliers, DB)

puts suppliers
  .restrict(Predicate.neq(status: 30))
  .to_sql

# SELECT `t1`.`sid`, `t1`.`name`, `t1`.`status`, `t1`.`city` FROM `suppliers` AS 't1' WHERE (`t1`.`status` != 30)
```

## Supported operators

```
r.allbut([:a, :b, ...])                      # remove specified attributes
r.autowrap(split: '_')                       # structure a flat relation, split: '_' is the default
r.autosummarize([:a, :b, ...], x: :sum)      # (experimental) usual summarizers supported
r.constants(x: 12, ...)                      # add constant attributes (sometimes useful in unions)
r.extend(x: ->(t){ ... }, ...)               # add computed attributes
r.group([:a, :b, ...], :x)                   # relation-valued attribute from attributes
r.image(right, :x, [:a, :b, ...])            # relation-valued attribute from another relation
r.join(right, [:a, :b, ...])                 # natural join on a join key
r.join(right, :a => :x, :b => :y, ...)       # natural join after right reversed renaming
r.matching(right, [:a, :b, ...])             # semi join, aka where exists
r.matching(right, :a => :x, :b => :y, ...)   # semi join, after right reversed renaming
r.not_matching(right, [:a, :b, ...])         # inverse semi join, aka where not exists
r.not_matching(right, :a => :x, ...)         # inverse semi join, after right reversed renaming
r.page([[:a, :asc], ...], 12, page_size: 10) # paging, using an explicit ordering
r.prefix(:foo_, but: [:a, ...])              # prefix kind of renaming
r.project([:a, :b, ...])                     # keep specified attributes only
r.rename(a: :x, b: :y, ...)                  # rename some attributes
r.restrict(a: "foo", b: "bar", ...)          # relational restriction, aka where
r.rxmatch([:a, :b, ...], /xxx/)              # regex match kind of restriction
r.summarize([:a, :b, ...], x: :sum)          # relational summarization
r.suffix(:_foo, but: [:a, ...])              # suffix kind of renaming
r.union(right)                               # relational union
```
