# Bmg, a relational algebra (Alf's successor)!

Bmg is a relational algebra implemented as a ruby library. It implements the
[Relation as First-Class Citizen](http://www.try-alf.org/blog/2013-10-21-relations-as-first-class-citizen)
paradigm contributed with [Alf](http://www.try-alf.org/) a few years ago.

Like Alf, Bmg can be used to query relations in memory, from various files,
SQL databases, and any data sources that can be seen as serving relations.
Cross data-sources joins are supported, as with Alf. For differences with Alf,
see a section further down this README.

## Outline

* [Example](#example)
* [Where are base relations coming from?](#where-are-base-relations-coming-from)
  * [Connecting to SQL databases](#connecting-to-sql-databases)
* [List of supported operators](#supported-operators)
* [How is this different?](#how-is-this-different)
  * [... from similar libraries](#-from-similar-libraries)
  * [... from Alf](#-from-alf)

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

### Connecting to SQL databases

Bmg requires `sequel >= 3.0` to connect to SQL databases.

```ruby
require 'sqlite3'
require 'bmg'
require 'bmg/sequel'

DB = Sequel.connect("sqlite://suppliers-and-parts.db")

suppliers = Bmg.sequel(:suppliers, DB)

big_suppliers = suppliers
  .restrict(Predicate.neq(status: 30))

puts big_suppliers.to_sql
# SELECT `t1`.`sid`, `t1`.`name`, `t1`.`status`, `t1`.`city` FROM `suppliers` AS 't1' WHERE (`t1`.`status` != 30)

puts JSON.pretty_generate(big_suppliers)
# [{...},...]
```

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

## Who is behind Bmg?

Bernard Lambeau (bernard@klaro.cards) is Alf & Bmg main engineer & maintainer.

Enspirit (https://enspirit.be) and Klaro App (https://klaro.cards) are both
actively using and contributing to the library.

Feel free to contact us for help, ideas and/or contributions. Please use github
issues and pull requests if possible if code is involved.
