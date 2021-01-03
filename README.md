# Bmg, a relational algebra (Alf's successor)!

Bmg is a relational algebra implemented as a ruby library. It implements the
[Relation as First-Class Citizen](http://www.try-alf.org/blog/2013-10-21-relations-as-first-class-citizen)
paradigm contributed with [Alf](http://www.try-alf.org/) a few years ago.

Bmg can be used to query relations in memory, from various files, SQL databases,
and any data source that can be seen as serving relations. Cross data-sources
joins are supported, as with Alf. For differences with Alf, see a section
further down this README.

## Outline

* [Example](#example)
* [Where are base relations coming from?](#where-are-base-relations-coming-from)
  * [Memory relations](#memory-relations)
  * [Connecting to SQL databases](#connecting-to-sql-databases)
  * [Reading files (csv, excel, text)](#reading-files-csv-excel-text)
* [List of supported operators](#supported-operators)
* [How is this different?](#how-is-this-different)
  * [... from similar libraries](#-from-similar-libraries)
  * [... from Alf](#-from-alf)
* [Contribute](#contribute)
* [License](#license)

## Example

```ruby
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
  .exclude(status: 30)
  .extend(upname: ->(t){ t[:name].upcase })
  .group([:sid, :name, :status], :suppliers_in)

puts JSON.pretty_generate(by_city)
# [{...},...]
```

## Where are base relations coming from?

Bmg sees relations as sets/enumerable of symbolized Ruby hashes. The following
sections show you how to get them in the first place, to enter Relationland.

### Memory relations

If you have an Array of Hashes -- in fact any Enumerable -- you can easily get
a Relation using either `Bmg::Relation.new` or `Bmg.in_memory`.

```ruby
# this...
r = Bmg::Relation.new [{id: 1}, {id: 2}]

# is the same as this...
r = Bmg.in_memory [{id: 1}, {id: 2}]

# entire algebra is available on `r`
```

### Connecting to SQL databases

Bmg currently requires `sequel >= 3.0` to connect to SQL databases. You also
need to require `bmg/sequel`.

```ruby
require 'sqlite3'
require 'bmg'
require 'bmg/sequel'
```

Then `Bmg.sequel` serves relations for tables of your SQL database:

```ruby
DB = Sequel.connect("sqlite://suppliers-and-parts.db")
suppliers = Bmg.sequel(:suppliers, DB)
```

The entire algebra is available on those relations. As long as you keep using
operators that can be translated to SQL, results remain SQL-able:

```ruby
big_suppliers = suppliers
  .exclude(status: 30)
  .project([:sid, :name])

puts big_suppliers.to_sql
# SELECT `t1`.`sid`, `t1`.`name` FROM `suppliers` AS 't1' WHERE (`t1`.`status` != 30)
```

Operators not translatable to SQL are available too (such as `group` below).
Bmg fallbacks to memory operators for them, but remains capable of pushing some
operators down the tree as illustrated below (the restriction on `:city` is
pushed to the SQL server):

```ruby
Bmg.sequel(:suppliers, sequel_db)
  .project([:sid, :name, :city])
  .group([:sid, :name], :suppliers_in)
  .restrict(city: ["Paris", "London"])
  .debug

# (group
#   (sequel SELECT `t1`.`sid`, `t1`.`name`, `t1`.`city` FROM `suppliers` AS 't1' WHERE (`t1`.`city` IN ('Paris', 'London')))
#   [:sid, :name, :status]
#   :suppliers_in
#   {:array=>false})
```

### Reading files (csv, excel, text)

Bmg provides simple adapters to read files and reach Relationland as soon as
possible.

#### CSV files

```ruby
csv_options = { col_sep: ",", quote_char: '"' }
r = Bmg.csv("path/to/a/file.csv", csv_options)
```

Options are directly transmitted to `::CSV.new`, check ruby's standard
library.

#### Excel files

You will need to add [`roo`](https://github.com/roo-rb/roo) to your Gemfile to
read `.xls` and `.xlsx` files with Bmg.

```ruby
roo_options = { skip: 1 }
r = Bmg.excel("path/to/a/file.xls", roo_options)
```

Options are directly transmitted to `Roo::Spreadsheet.open`, check roo's
documentation.

#### Text files

There is also a straightforward way to read text files and convert lines to
tuples.

```ruby
r = Bmg.text_file("path/to/a/file.txt")
r.type.attrlist
# => [:line, :text]
```

Without options tuples will have `:line` and `:text` attributes, the former
being the line number (starting at 1) and the latter being the line itself
(stripped).

The are a couple of options (see `Bmg::Reader::Textfile`). The most useful one
is the use a of a Regexp with named captures to automatically extract
attributes:

```ruby
r = Bmg.text_file("path/to/a/file.txt", parse: /GET (?<url>([^\s]+))/)
r.type.attrlist
# => [:line, :url]
```

In this scenario, non matching lines are skipped. The `:line` attribute keeps
being used to have at least one candidate key (so to speak).

## Supported operators

```ruby
r.allbut([:a, :b, ...])                      # remove specified attributes
r.autowrap(split: '_')                       # structure a flat relation, split: '_' is the default
r.autosummarize([:a, :b, ...], x: :sum)      # (experimental) usual summarizers supported
r.constants(x: 12, ...)                      # add constant attributes (sometimes useful in unions)
r.extend(x: ->(t){ ... }, ...)               # add computed attributes
r.exclude(predicate)                         # shortcut for restrict(!predicate)
r.group([:a, :b, ...], :x)                   # relation-valued attribute from attributes
r.image(right, :x, [:a, :b, ...])            # relation-valued attribute from another relation
r.join(right, [:a, :b, ...])                 # natural join on a join key
r.join(right, :a => :x, :b => :y, ...)       # natural join after right reversed renaming
r.left_join(right, [:a, :b, ...], {...})     # left join with optional default right tuple
r.left_join(right, {:a => :x, ...}, {...})   # left join after right reversed renaming
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
t.transform(:to_s)                           # all-attrs transformation
t.transform(&:to_s)                          # similar, but Proc-driven
t.transform(:foo => :upcase, ...)            # specific-attrs tranformation
t.transform([:to_s, :upcase])                # chain-transformation
r.union(right)                               # relational union
r.where(predicate)                           # alias for restrict(predicate)
```

## How is this different?

### ... from similar libraries?

1. The libraries you probably know (Sequel, Arel, SQLAlchemy, Korma, jOOQ,
   etc.) do not implement a genuine relational algebra: their support for
   chaining relational operators is limited (yielding errors or wrong SQL
   queries). Bmg **always** allows chaining operators. If it does not, it's
   a bug. In other words, the following query is 100% valid:

       relation
         .where(...)
         .union(...)
         .summarize(...)   # aka group by
         .restrict(...)

2. Bmg supports in memory relations, json relations, csv relations, SQL
   relations and so on. It's not tight to SQL generation, and supports
   queries accross multiple data sources.

3. Bmg makes a best effort to optimize queries, simplifying both generated
   SQL code (low-level accesses to datasources) and in-memory operations.

4. Bmg supports various *structuring* operators (group, image, autowrap,
   autosummarize, etc.) and allows building 'non flat' relations.

### ... from Alf?

If you use Alf in the past, below are the main differences between Bmg and
Alf. Bmg has NOT been written to be API-compatible with Alf and will probably
never be.

1. Bmg's implementation is much simpler than Alf, and uses no ruby core
   extention.

2. We are confident using Bmg in production. Systematic inspection of query
   plans is advised though. Alf was a bit too experimental to be used on
   (critical) production systems.

3. Alf exposes a functional syntax, command line tool, restful tools and
   many more. Bmg is limited to the core algebra, main Relation abstraction
   and SQL generation.

4. Bmg is less strict regarding conformance to relational theory, and
   may actually expose non relational features (such as support for null,
   left_join operator, etc.). Sharp tools hurt, use them with care.

5. Bmg does not implement all operators documented on try-alf.org, even if
   we plan to eventually support most of them.

6. Bmg has a few additional operators that prove very useful on real
   production use cases: prefix, suffix, autowrap, autosummarize, left_join,
   rxmatch, etc.

7. Bmg optimizes queries and compiles them to SQL on the fly, while Alf was
   building an AST internally first. Strictly speaking this makes Bmg less
   powerful than Alf since optimizations cannot be turned off for now.

## Contribute

Please use github issues and pull requests for all questions, bug reports,
and contributions. Don't hesitate to get in touch with us with an early code
spike if you plan to add non trivial features.

## Licence

This software is distributed by Enspirit SRL under a MIT Licence. Please
contact Bernard Lambeau (blambeau@gmail.com) with any question.

Enspirit (https://enspirit.be) and Klaro App (https://klaro.cards) are both
actively using and contributing to the library.
