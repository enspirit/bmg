# 0.18.8

* Fix SQL compilation of summarize expressions having a resulting attribute
  name different from the attribute summarized.

* Add `distinct_count` summarizer, with SQL compilation.

# 0.18.7 - 2021-06-14

* `transform` now supports a ruby Class transformer. `Integer`, `Float` and
  `String` are natively supported (through `Integer()` and `Float()` for the
  formers, `to_s` for the latter). The class must respond to `parse`
  otherwise, which works with `Date`, `DateTime`, `URI`, etc. `nil` are
  always returned unchanged.

* `transform` is compiled to SQL CAST expressions when used with scalar classes
  (String, Integer, Float, Date, DateTime). The compiler is able to split
  complex transformations into SQL-supported and SQL-unsupported transformations
  so that everything that can be pushed down the tree is pushed.

* Add a `:preserve` option to `image` that prevents the application of
  `allbut(on)` on the tuples of the `right` relation when creating the
  resulting attribute. Default behavior unchanged.

# 0.18.6 - 2021-06-10

* Add `ungroup` operator.

* Add `unwrap` operator.

* Fix `Summarize.value_by` when using `symbolize: true` and a default value.

# 0.18.5 - 2021-06-08

* Add a Summarize.value_by that allows flipping vertical series to a
  tuple-valued attribute.

* Fix CSV read/write usage under ruby-3.0.

# 0.18.4 - 2021-05-11

* `Bmg.excel` now strips attribute names.

* `Relation#transform` now accepts a Hash whose keys are ruby classes,
  The corresponding transformation is applied to all values belonging
  to the class.

* Fix `r.rename(...).rename(...)` yielding a private method call error.

* Add `Summarizer.median(x)` as a shortcut for `Summarizer.percentile(x, 50)`

* `Summarizer.percentile` now returns a decimal number and not an integer.

* Add `Summarizer.percentile_cont` and `Summarizer.percentile_disc` like
  PostgreSQL (for continuous and discrete) ; the default `percentile` is
  the continuous version.

# 0.18.3 - 2021/05/06

* Add `Relation#to_xlsx` to create Excel files from Relations. The
  feature requires 'bmg/writer/xlsx' and the 'write_xlsx' ruby gem,
  the latter being not a dependency of Bmg at this point.

* `Bmg.excel` generates tuples with a `:row_num` attribute ; it's a
  unique index starting at 1. A `:row_num` option may be set to `false`
  to not generate them, or to a Symbol to choose it's name.

* `Bmg.csv`'s options now support a `:smart` flag that can be set to
  true (resp. false) if you want (resp. don't want) Bmg to to identify
  quotes and separators by itself. The flag is currently true by default
  (unless input is an IO) for backward compatibility reasons but will
  likely be set to false in the future. Consider using the flag explicitely
  to prevent surprises.

* `Bmg.csv` now correctly handles `IO` and `StringIO` input instances.
  Using such an input with `:smart => true` might lead to problems unless
  the io can be read multiple times in a row.

* `distinct` summarizer as beed added. Collects distinct values as
  and array.

* `percentile(:attr, nth)` summarizer as beed added. Collects the nth
  percentile via a sort method (O(n) memory requirement!)

* `Summarizer.by_proc(least){|t,memo| ... }` can now be used to factor a
  summarizer that works like `each_with_object`. `least` is the initial
  value, and defaults to nil.

* `Relation#each` now returns an Enumerator when called without block.

* `Relation#with_attr_list` ensures that an attribute list is known on
  the type, consuming the first tuple to discover them if needed.

# 0.18.2 - 2021/04/16

* Add Relation#count that returns the exact number of tuples in
  the relation.

  The default implementation consumes the tuples to count them.
  Push-down optimizations implemented for base operators that do not
  affect the number of resulting tuples.

  Sequel::Relation pushes a `SELECT COUNT(*)` to the SQL engine.

* Optimize `allbut.project`, push the projection down the tree.

* Optimize `image.project`, push the projection down the tree if
  possible. If the newly introduced attribute is kept no optimization
  is down (yet). In particular a sub-projection is not pushed down
  the tree, as the semantics need careful thinking.

* Optimize `autowrap.project`, push the projection down the tree if
  possible.

# 0.18.1 - 2021/04/15

* Image's :array option now support an ordering relation. The
  tuples will then be sorted in the resulting array.

* Autosummarize now has `same`, `group`, `y_by_x` and `ys_by_x`
  factory methods.

* Autosummarize `y_by_x` and `ys_by_x` now support `nil` and
  simply ignore them.

* Add `images` shortcut, that (currently) compiles to a sequence
  of `image`.

* Optimize `allbut.allbut`. But lists are merged and only one `allbut`
  is kept.

* Optimize `image.allbut` in case where the new image attribute is
  thrown away. The image can be removed alltogether.

* Optimize `transform.allbut`. The allbut can always be pushed down
  the tree.

* Optimize `transform.project`. The project can always be pushed down
  the tree.

* Optimize `transform.restrict`. Push whatever can be pushed down the
  tree.

* Optimize `allbut.page`. Push the page down the tree if allbut is
  key preserving.

* Optimize `allbut.matching`. Push the matching down the tree, it's
  always possible.

* Optimize `page.matching`. Push the matching down the tree, as long
  as the join clause does not use the new image attribute.

* Optimize `autowrap.matching`. Push the matching down the tree, as
  long as the join clause only uses untouched attributes.

# 0.18.0 - 2021/03/12

* Default Relation#type is provided, that returns Bmg::Type::ANY

* Add Bmg.text_file to easily parse then query text files,
  with out of the box support for named regular expressions.

* Add Relation#with_type

* Add TupleAlgebra#symbolize_keys

* Relation#transform now supports Regexp transformation. When a match
  is found, transformed value is the match's `to_s`, otherwise it is
  nil.

* Add Relation#where(p) as an alias for restrict(p)

* Add Relation#exclude(p), a shortcut for restrict(!p)

# 0.17.8 - 2020/09/10

* Relation#to_csv now accepts an OutputPreference object (or hash)
  allowing to specify an attributes ordering.

# 0.17.7 - 2020/09/10

* TupleTransformer now allows using a Hash as attribute transformation.
  E.g.,

      r = Bmg::Relation.new [{:foo => "x"}, {:foo => "y"}]
      r2 = r.transform(foo: { "x" => 1, "y" => 2 })
      r2.to_a  # [{:foo => 1}, {:foo => 2}]

# 0.17.6 - 2020/08/28

* Add a Relation::Proxy module that helps constructing object collections
  on top of Bmg Relations.

* Add Relation#transform, for easier attribute transformations than
  #extend.

  TRANSFORM uses ruby semantics for now, is not compiled to SQL, and
  provides no optimization so far. It makes various transformations
  much easier than before:

      # Will apply attr.to_s on every attribute
      relation.transform(:to_s)
      relation.transform(&:to_s)

      # Will apply attr.to_s.upcase on every tuple attribute
      relation.transform([:to_s, :upcase])

      # Will selectively apply on attributes
      relation.transform(:foo => :upcase, :bar => ->(bar){ bar*2 })

  EXTEND is supposed to be used for adding attributes only, not
  transforming existing ones. The introduction of TRANSFORM makes this
  clearer by providing an official alternative. The aim is to make
  formal logic (e.g. optimizer) slightly more powerful, through PRE
  strengtening (in 1.0) along those rules.

# 0.17.5 - 2020/08/17

* Add Relation#to_csv, for easier .csv file generation from relational
  data.

* Fix path dependency.

# 0.17.4 - 2020/07/23

* Fix SQL compilation when using INTERSECT predicates. INTERSECT
  was seen as SQL's INTERSECT, which exists too.

# 0.17.3 - 2020/07/09

* Fix SQL compilation of JOIN when operands restrict on attributes
  having the same name (without being part of the JOIN clause
  itself). A bug in Predicate was loosing one AND term.

* Add Relation#left_join operator, with support for SQL generation.

  Left join is NOT relational, as it introduces NULLs. For this reason
  Bmg's left join allows specifying a default_right_tuple to replace
  those generated NULLs by actual values.

  SQL support: Mixing normal `join`s and `left_join`s in an arbitrary
  order may yield SQL anomalies or semantically wrong generated SQL
  code. It is currently good practice to avoid normal joins as soon
  as a `left_join` has been used.

# 0.17.2 - 2020/05/15

* Fix SQL compilation of `summarize` when the summarization by has more
  than one attribute.

# 0.17.1 - 2020/04/29

* Bump predicate dependency to min 2.3.1, to get a bug fix on image
  optimization.

# 0.17.0 - 2020/04/21

* Optimize Image operator. By default, and when possible, the right
  operand is restricted to only those matching the left tuples before
  being iterated.

  This is possible when the join key (`on`) contains exactly one attribute
  (after having removed attributes that are known to be bound to a single
  literal). The matching process requires materializing the left operand
  for extracting its keys. Restrict then uses `Predicate.in(on.first => ...)`.

  This is now the default option, under the assumption that `right` operand
  is frequently (much) bigger that left (images frequently occur along 1-N
  foreign keys). The option fallbacks to a simpler algorithm when both
  operands are filtered in such way that `on` is empty, which is the second
  most frequent usage.

# 0.16.6 - 2020/01/31

* Force Predicate >= 2.2.1 to avoid an wrong optimizations when
  chaining restrictions with in and eq on same variable.

# 0.16.5 - 2019/12/13

* Add Relation#y_by_x to get a Hash with y (last) value mapped to
  each x.

# 0.16.4 - 2019/10/16

* Allow Sequel's qualified name to be used like Symbols to denote
  base tables.

# 0.16.3 - 2019/10/09

* Fix SQL generation when joining with a summarize.

# 0.16.2 - 2019/07/09

* Fix `autowrap` post-processing on multiple level cases. Guarantees that when
  the result of `autowrap` contains hashes with only `nil` values, the post-
  processing will apply.

# 0.16.1 - 2019/06/09

* Fix SQL compilation of restrict expressions using Predicate.in
  with nil.

# 0.16.0 - 2019/05/31

* Improve SQL compilation of expressions involving multiple JOINs.
  While the former version used a lot of subqueries and/or common
  table expressions (aka. WITH) in such cases, this version
  linearizes all joins with CROSS and INNER JOIN clauses.

* Optimize `autowrap.autowrap` when applying to the exact same
  options. A single autowrap is kept in such cases.

* Optimize `join.autowrap` in cases the join can be pushed down
  the tree and autowrapping applied afterwards. Variants of this
  optimization are implemented using both left and right operands,
  in the hope to move autowrap up the tree and remove unnecessary
  ones.

* Optimize `autowrap.rename`, in case the renaming can be safely
  pushed down the tree, that is, when it does not apply to wrapped
  attributes and does not yield after-the-fact autowrapping.

* Optimize `rename` when the actual renaming is empty or canonical
  (i.e. old and new attribute names are the same). Also simplify the
  renaming list by removing canonical entries.

* Add a `:but` options to `prefix` and `suffix` that allows excluding
  certain attributes from the resulting rename.

* Add `{x1 => y1, ..., xn => yn}` shorthands to `matching`, `not_matching`
  and `image` operators. Similar to the shorthand introduced in 0.14.6
  for `join`, based on an inversed renaming on the right operand.

* Adds Summarize operator with avg, collect, contact, count, max, min,
  stddev, sum and variable summarizers. Only avg, count, min, max and sum
  compile to SQL for now.

* Prevents unnecessary DISTINCT when making a restrict+allbut chaining
  that preserves a reduced key, e.g.,

      supplies.restrict(sid: 'SID').allbut([:sid])

  no longers generates a DISTINCT, even is `sid` is originally part of
  `supplies`'s primary key.

* Fix Predicate::NotSupportedError being raised when renaming a
  restriction using a native expression. In such case, type
  inference now removes the type predicate and replaces it by a
  tautology.

# 0.15.0 - 2019/01/30

* Optimize `extend.allbut` and `extend.project` to strip unnecessary
  extensions, or simplify them to avoid unnecessary computed attributes.

* Optimize `extend.join` but pushing the join down the tree when the
  extension attributes are not part the join at all.

* Optimize `extend.rename` by pushing the renaming down the tree for
  all attributes not introduced by the extension, and renaming the
  extension attributes themselves otherwise.

  Add TupleAlgebra.rename as a side effect.

* Optimize `extend.matching` and `extend.not_matching` by pushing the
  match operators down the tree when match attributes do not overlap
  with extension attributes.

* Slightly improve SQL compilation to avoid generating WITH expressions
  on join expressions having only simple terms on right. That is,
  previously, `x.join(y).join(z)` yield a WITH expression for
  `x.join(y)`, while inner join clauses are correctly chained now.
  `x.join(y.join(z))` will still generate a WITH expression for
  `y.join(z)` though.

# 0.14.6 - 2019/01/29

* Add `left.join(right, {x1 => y1, ..., xn => yn})` as a shorthand for
  `left.join(right.rename({y1 => x1, ..., yn => xn}, [x1,...,xn])`.
  This allows joining ala SQL, i.e. with attributes differing on each
  operand. A difference with SQL, though, is that the `ys` attributes
  are no longer present in the join result.

# 0.14.5 - 2019/01/23

* Optimize `extend.page` by pushing the page down the tree when
  extension attributes and page ordering attributes are disjoint.

# 0.14.4

* Fix error when tracing expressions involving autosummarizations with
  YByX and YsByX

# 0.14.3

* Add support for optional type checking through Type#with_typecheck
  and Type#without_typecheck.

  Type checking is disabled by default, and only check for attribute
  presence, absence and no-clash policy on the various available
  operators.

* Add Relation#materialize (Relation::Materialized) that ensures that
  the operand is consumed only once and the result kept in memory if
  reused later one.

# 0.14.2

* Added a schema in Sequel type inference mechanism. Otherwise, indices
  are loaded multiple times because Sequel itself does not cache them.
  (not part of the cache_schema: true) behavior.

# 0.14.1

* Fix Operator::Project mutating origin tuples.

# 0.14.0

* BREAKING CHANGE (since 0.10.0 actually): most update fail when trying
  to make them on a Relation::Sequel instance. SQL compilation mechanism
  lacks the update rules implemented in various operators.

* Fix the Sequel translation in presence of a WHERE clause involving
  IN with subqueries.

# 0.13.0 - May 31st, 2018

* SQL compilation now support the `constants` operator.

* SQL compilation now support nary-union, intersect and except,
  provided they have the same modifier.

* Optimization: Any relation unioned with empty returns itself.

* Optimization: All relations return self if allbut is called
  with and empty attribute list.

* Optimization: calling `constants` on empty returns an empty
  relation.

# 0.12.0 - May 29st, 2018

* Add NotMatching operator, with restrict optimization and SQL
  compilation.

* Optimize `autowrap.page` by pushing the page down the tree when
  autowrap attributes are known and the page ordering does not touch
  them.

* Enhance key inference on Join, when joining on a candidate key
  of the right operand. In such case, the left keys can all be kept
  unchanged.

* Fix a SQL compilation bug with join expressions in subqueries.
  Requalification of table names was forgotten in inner join
  clauses.

# 0.11.0 - May 29st, 2018

* Add Prefix and Suffix shortcut operators for longer Rename
  expressions. Attrlist must be known on operand's type.

* Add Join operator, with explicit attribute list for join key.

* Attrlist, Key and Predicate inference is now correctly implemented
  on autowrap.

# 0.10.1

* Fix Page implementation to support full ordering, e.g
  `[[:name, :desc], [:id, :asc]]`

# 0.10.0 - May 28st, 2018

* BREAKING CHANGE: `rxmatch` is now case sensitive by default.

* BREAKING CHANGE: you should now use `Bmg.sequel(:table_name, db)`
  instead of `Bmg.sequel(db[:table_name])` to avoid unnecessary long
  SQL from being generated.

* `rxmatch` becomes a shortcut operator, that translates to a `restrict`
  with a OR using Predicate#match. This aims at reusing all existing
  `restrict` optimizations for `rxmatch`, with a free implementation
  cost.

* Add Restrict optimization: pust it over `autowrap` when the list of
  attributes are known statically and the predicate does not use any
  of the wrapped new attributes.

* Add Page optimizations: push it over `constants, `rename` and `image`
  when possible.

* The Sequel contribution now generates valid SQL in all cases and
  performs necessary optimizations.

# 0.9.1 - May 16st, 2018

* Fix Rxmatch that now applies matching in a case insensitive way by
  default when used with a String. A `case_sensitive: true` option
  can be specified to change that behavior.

# 0.9.0 - May 16st, 2018

* Add the Page operator: filters on n tuples according to an ordering
  and a given page size and page index. No optimization implemented yet.

* Add the Rxmatch operator: filters tuples whose subset of attributes
  match a given string or regular expression when concatanated together
  by a space. Restrict optimization is implemented.

* The expression `r.matching(...)` now correctly preserves the same type
  as `r`.

# 0.8.0 - May 16st, 2018

* Add the Group operator: groups some attributes of the operand as a
  new relation-valued attribute. Restrict optimization is implemented.

# 0.7.1 - May 14st, 2018

* Fixes the restrict optimization on Matching, that led forgetting about
  the join key

# 0.7.0 - May 14st, 2018

* Add the Matching operator: filters the left operand to tuples that have
  at least a matching tuple on right operand on a given shared join key.
  Restrict optimization is implemented.

# 0.6.1 - March 30st, 2018

* The default implementation of `Relation::Type` now exposes the relation
  predicate, when known.

# 0.6.0 - March 16st, 2018

* Add `Relation#ys_by_x` consumption method, that converts a relation to a
  Hash mapping `tuple[x]` keys to `[tuple[y]]` values. This is similar to
  a given summary with autosummarize, but provided as a consumption method.
  The options support specifying an order and whether ys must be distinct.

* Add `Relation#empty?`

* Add `Relation#visit` that allows visiting an expression tree with a block.
  The block is yield with every (relation, parent) pair in a depth first
  search walk of the tree.

* `Relation#to_s` and `Relation#inspect` now provide a friendly representation
  of the expression tree. This is used to improve what `#debug` prints on
  its argument.

* `Relation::Sequel#insert` now inserts known attribute constants inherited
  from the relvar predicate. This means that

      rel.restrict(x: 2).allbut([:x]).insert(y: 7)

  will actually insert the tuple `{x: 2, y: 7}` in the underlying SQL table.

* Fix `rename.restrict` optimization that failed with an UnsupportedError
  on native predicate.

* Objects obtained through `Bmg.csv` and `Bmg.excel` and now real Relation
  instances, and no longer tuple enumerabled.

* Add a spying mechanism that allows analyzing tree expressions just before
  each is called. This works by calling `spied(spy)` on relations, just like
  other operators. The spied operator always stays on top of the expression
  tree, by a delegation mechanism when algebra methods are called. When the
  relation is eventually consumed, it calls the `spy` argument with itself.
  The spy has the opportunity to inspect the expression tree, and act
  accordingly (e.g. raising an error if something strange is detected).

# 0.5.0 - March 13st, 2018

* Update mechanism (insert, delete & update) is provided for operators yielding
  no update ambiguity: allbut, constants, extend, project, rename.

* Optimization: push restrictions over autosummarize, rename & restrict.

* Added Relation#to_json

* Predicate required version is bumped to 1.3.0, that contains an important
  security fix.

# 0.4.1 - March 9st, 2018

* Fix Image#restrict optimization that pushed down restrictions on right attributes
  that do not exist for it.

* Optimize tautolological restrictions by always returning the operand itself. This
  way, it is no longer necessary to use `unless p.tautology?` before using `restrict`.

* Optimize contraduction restrictions by always returning an empty relation. This
  will further optimize since many optimizations are implemented on Relation::Empty
  itself.

* Predicate dependency bumped to 1.2.0 to get a few bug fixes.

# 0.4.0 - March 7st, 2018

* Optimization: push restrictions over image & constants.

* Optimization: stack subsequent unions as only one n-adic operator.

* Introduce `Relation.empty` for empty relations taken into account by the optimization.

# 0.3.0 - March 7st, 2018

* Add the Constants operator: extends the operand's tuple with attributes whose values are
  known statically. This is a special case of extension where values are not Proc but constants.

* Add the Image operator: extends the operand's tuple with the relational image on a right
  operand. Unlike Alf, the join attributes are explicit for now.

* Add the Restrict operator: restrict filters the operand tuples to those for which a predicate
  evaluates to true.

* Add the Union operator: union returns both the tuples from left and right operands, but
  strips the duplicates, if any.

* Add connectivity to real SQL database, through Sequel. require 'bmg/sequel' is needed first.
  It contributes a `Bmg.sequel(dataset)` method that returns relation instances over Sequel
  dataset objects.

* Optimization: push restrict over allbut, project, union & constants.

* Optimization: convert double restrict to a predicate conjunction.

# 0.2.0 - January 13st, 2018

* Add the Extend operator: extends operand tuples with attributes resulting from specified
  computations.

* Add Relation#one (and Relation#one_or_nil), that returns the tuple of a singleton or raises
  an error (or returns nil).

# 0.1.1 - January 9st, 2018

* Options passed to Reader::Excel and Bmg.excel are passed, unchanged to Roo::Spreadsheet.
  Now, all options from Roo are thus compatible with Bmg.

# 0.1.0 - November 23st, 2017

* Birth.
