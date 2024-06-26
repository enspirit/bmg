# Bmg, a relational algebra (Alf's successor)!

Bmg is a relational algebra implemented as a Ruby library. It implements the
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
  * [Reading data files](#reading-data-files-json-csv-yaml-text-xls--xlsx)
  * [Connecting to Redis databases](#connecting-to-redis-databases)
  * [Your own relations](#your-own-relations)
* [The Database abstraction](#the-database-abstraction)
* [List of supported operators](#supported-operators)
* [List of supported predicates](#supported-predicates)
* [List of supported summaries](#supported-summaries)
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

### Reading data files (json, csv, yaml, text, xls & xlsx)

Bmg provides simple adapters to read files and reach Relationland as soon as
possible.

#### JSON files

```ruby
r = Bmg.json("path/to/a/file.json")
```

The json file is expected to contain tuples of same heading.

#### YAML files

```ruby
r = Bmg.yaml("path/to/a/file.yaml")
```

The yaml file is expected to contain tuples of same heading.

#### CSV files

```ruby
csv_options = { col_sep: ",", quote_char: '"' }
r = Bmg.csv("path/to/a/file.csv", csv_options)
```

Options are directly transmitted to `::CSV.new`, check Ruby's standard
library. If you don't provide them, `Bmg` uses `headers: true` (hence making
then assumption that attributes names are provided on first line), and makes a
best effort to infer the column separator.

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

#### Excel files

You will need to add [`roo`](https://github.com/roo-rb/roo) to your Gemfile to
read `.xls` and `.xlsx` files with Bmg.

```ruby
roo_options = { skip: 1 }
r = Bmg.excel("path/to/a/file.xls", roo_options)
```

Options are directly transmitted to `Roo::Spreadsheet.open`, check roo's
documentation.

### Connecting to Redis databases

Bmg currently requires `bmg-redis` and `redis >= 4.6` to connect
to Redis databases. You also need to require `bmg/redis`.

```Gemfile
gem 'bmg'
gem 'bmg-redis'
```

```ruby
require 'redis'      #  also done by 'bmg/redis' below
require 'bmg'
require 'bmg/redis'
```

Then, you can create Redis relation variables (aka relvars) like
this:

```ruby
type = Bmg::Type::ANY.with_keys([[:id]])
r = Bmg.redis(type, {
  key_prefix: "suppliers",
  redis: Redis.new,
  serializer: :marshal,
  ttl: 365 * 24 * 60 * 60
})
```

The key prefix will be used to distinguish the tuples from other elements in the
same database (e.g. tuples from other relvars). The serializer is either
`:marshal` or `:json`. Please note that types are not preserved when using the
second one (all attribute values will come back as strings, but keys will be
symbolized). The `ttl` is used to set the validity period of a tuple in redis
and is optional.

The redis relvars support basic algorithms for insert/update/delete.
No optimization is currently supported.

### Your own relations

As noted earlier, Bmg has a simple relation interface where you only have to
provide an iteration of symbolized tuples.

```ruby
class MyRelation
  include Bmg::Relation

  def each
    yield(id: 1, name: "Alf", year: 2014)
    yield(id: 2, name: "Bmg", year: 2018)
  end
end

MyRelation.new
  .restrict(Predicate.gt(:year, 2015))
  .allbut([:year])
```

As shown, creating adapters on top of various data source is straighforward.
Adapters can also participate to query optimization (such as pushing
restrictions down the tree) by overriding the underscored version of operators
(e.g. `_restrict`).

Have a look at `Bmg::Algebra` for the protocol and `Bmg::Sql::Relation` for an
example. Keep in touch with the team if you need some help.

## The Database abstraction

The previous section focused on obtaining *relations*. In practice you frequently
have a collection of relations hence a *database*:

* A SQL database with multiple tables
* A list of data files, all in the same folder
* An excel file with various sheets

Bmg supports a simple Datbabase abstraction that serves those relations "by name",
in a simple way. A database can also be easily dumped back to a data folder of
json or csv files, or as simple xlsx files with multiple sheets.

### Connecting to a SQL Database

For a SQL database, connected with Sequel:

```
db = Bmg::Database.sequel(Sequel.connect('...'))
db.suppliers # yields a Bmg::Relation over the `suppliers` table
```

### Connecting to data files in the same folder

Data files all in the same folder can be seen as a very basic form of database,
and served as such. Bmg supports `json`, `csv` and `yaml` files:

```
db = Bmg::Database.data_folder('./my-database')
db.suppliers # yields a Bmg::Relation over the `suppliers.(json,csv,yml)` file
```

Bmg supports files in different formats in the same folder. When files with the
same basename exist, json is prefered over yaml, which is prefered over csv.

### Dumping a Database instance

As a data folder:

```
db = Bmg::Database.sequel(Sequel.connect('...'))
db.to_data_folder('path/to/folder', :json)
```

As an .xlsx file (any existing file will be erased, we don't support modifying
existing files):

```
require 'bmg/xlsx'
db.to_xlsx('path/to/file.xlsx')
```

## Supported operators

```ruby
r.allbut([:a, :b, ...])                      # remove specified attributes
r.autowrap(split: '_')                       # structure a flat relation, split: '_' is the default
r.autosummarize([:a, :b, ...], x: :sum)      # (experimental) usual summarizers supported
r.constants(x: 12, ...)                      # add constant attributes (sometimes useful in unions)
r.cross_product(right)                       # cross product, alias `cross_join`
r.extend(x: ->(t){ ... }, ...)               # add computed attributes
r.extend(x: :y)                              # shortcut for r.extend(x: ->(t){ t[:y] })
r.exclude(predicate)                         # shortcut for restrict(!predicate)
r.group([:a, :b, ...], :x)                   # relation-valued attribute from attributes
r.image(right, :x, [:a, :b, ...])            # relation-valued attribute from another relation
r.images({:x => r1, :y => r2}, [:a, ...])    # shortcut over image(r1, :x, ...).image(r2, :y, ...)
r.join(right, [:a, :b, ...])                 # join on a join key
r.join(right, :a => :x, :b => :y, ...)       # join after right reversed renaming
r.left_join(right, [:a, :b, ...], {...})     # left join with optional default right tuple
r.left_join(right, {:a => :x, ...}, {...})   # left join after right reversed renaming
r.matching(right, [:a, :b, ...])             # semi join, aka where exists
r.matching(right, :a => :x, :b => :y, ...)   # semi join, after right reversed renaming
r.minus(right)                               # set difference
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
r.transform(:to_s)                           # all-attrs transformation
r.transform(&:to_s)                          # similar, but Proc-driven
r.transform(:foo => :upcase, ...)            # specific-attrs tranformation
r.transform([:to_s, :upcase])                # chain-transformation
r.ungroup([:a, :b, ...])                     # ungroup relation-valued attributes within parent tuple
r.ungroup(:a)                                # shortcut over ungroup([:a])
r.union(right)                               # set union
r.unwrap([:a, :b, ...])                      # merge tuple-valued attributes within parent tuple
r.unwrap(:a)                                 # shortcut over unwrap([:a])
r.where(predicate)                           # alias for restrict(predicate)
```

## Supported Predicates

Usual operators are supported and map to their SQL equivalent as expected:

```ruby
Predicate.eq                                 # =
Predicate.neq                                # <>
Predicate.lt                                 # <
Predicate.lte                                # <=
Predicate.gt                                 # >
Predicate.gte                                # >=
Predicate.in                                 # SQL's IN
Predicate.is_null                            # SQL's IS NULL
```

See the [Predicate gem](https://github.com/enspirit/predicate) for a more
complete list.

Note: predicates that implement specific Ruby algorithms or patterns are
not compiled to SQL (and more generally not delegated to underlying database
servers).

## Supported Summaries

The `summarize` operator receives a list of `attr: summarizer` pairs, e.g.

```ruby
r.summarize([:city], {
  how_many: :count,        # same as how_many: Bmg::Summarizer.count
  status: :max,            # same as   status: Bmg::Summarizer.max(:status)
  min_status: Bmg::Summarizer.min(:status)
})
```

The following summarizers are available and translated to SQL:

```ruby
Bmg::Summarizer.count                      # count the number of tuples
Bmg::Summarizer.distinct(:a)               # collect distinct values (as an array)
Bmg::Summarizer.distinct_count(:a)         # count of distinct values
Bmg::Summarizer.min(:a)                    # min value for attribute :a
Bmg::Summarizer.max(:a)                    # max value
Bmg::Summarizer.sum(:a)                    # sum :a's values
Bmg::Summarizer.avg(:a)                    # average
```

The following summarizers are implemented in Ruby (they are supported when
querying SQL databases, but not compiled to SQL):

```ruby
Bmg::Summarizer.collect(:a)                # collect :a's values (as an array)
Bmg::Summarizer.concat(:a, opts: { ... })  # concat :a's values (opts, e.g. {between: ','})
Bmg::Summarizer.first(:a, order: ...)      # smallest seen a:'s value according to a tuple ordering
Bmg::Summarizer.last(:a, order: ...)       # largest seen a:'s value according to a tuple ordering
Bmg::Summarizer.variance(:a)               # variance
Bmg::Summarizer.stddev(:a)                 # standard deviation
Bmg::Summarizer.percentile(:a, nth)        # (continuous) nth percentile
Bmg::Summarizer.percentile_disc(:a, nth)   # discrete nth percentile
Bmg::Summarizer.value_by(:a, :by => :b)    # { :b => :a } as a Hash
```

## How is this different?

### ... from similar libraries?

1. The libraries you probably know (Sequel, Arel, SQLAlchemy, Korma, jOOQ,
   etc.) do not implement a genuine relational algebra. Their support for
   chaining relational operators is thus limited (restricting your expression
   power and/or raising errors and/or outputting wrong or counterintuitive
   SQL code). Bmg **always** allows chaining operators. If it does not, it's
   a bug.

   For instance the expression below is 100% valid in Bmg. The last where
   clause applies to the result of the summarize (while SQL requires a `HAVING`
   clause, or a `SELECT ... FROM (SELECT ...) r`).

      ```ruby
      relation
        .where(...)
        .union(...)
        .summarize(...)   # aka group by
        .where(...)
      ```

2. Bmg supports in-memory relations, JSON relations, csv relations, SQL
   relations and so on. It's not tight to SQL generation, and supports
   queries accross multiple data sources.

3. Bmg makes a best effort to optimize queries, simplifying both generated
   SQL code (low-level accesses to datasources) and in-memory operations.

4. Bmg supports various *structuring* operators (group, image, autowrap,
   autosummarize, etc.) and allows building 'non flat' relations.

5. Bmg can use full Ruby power when that helps (e.g. regular expressions in
   WHERE clauses or Ruby code in EXTEND clauses). This may prevent Bmg from
   delegating work to underlying data sources (e.g. SQL server) and should
   therefore be used with care though.

### ... from Alf?

If you use Alf (or used it in the past), below are the main differences between
Bmg and Alf. Bmg has NOT been written to be API-compatible with Alf and will
probably never be.

1. Bmg's implementation is much simpler than Alf and uses no Ruby core
   extention.

2. We are confident using Bmg in production. Systematic inspection of query
   plans is advised though. Alf was a bit too experimental to be used on
   (critical) production systems.

3. Alf exposes a functional syntax, command-line tool, restful tools and
   many more. Bmg is limited to the core algebra, main Relation abstraction
   and SQL generation.

4. Bmg is less strict regarding conformance to relational theory, and
   may actually expose non relational features (such as support for null,
   left_join operator, etc.). Sharp tools hurt, use them with care.

5. Unlike Alf::Relation instances of Bmg::Relation capture query-trees, not
   values. Currently two instances `r1` and `r2` are not equal even if they
   define the same mathematical relation. As a consequence joining on
   relation-valued attributes does not work as expected in Bmg until further
   notice.

6. Bmg does not implement all operators documented on try-alf.org, even if
   we plan to eventually support most of them.

7. Bmg has a few additional operators that prove very useful on real
   production use cases: prefix, suffix, autowrap, autosummarize, left_join,
   rxmatch, etc.

8. Bmg optimizes queries and compiles them to SQL on the fly, while Alf was
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
