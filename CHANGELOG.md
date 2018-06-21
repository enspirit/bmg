# 0.14.0

* BREAKING CHANGE (since 0.10.0 actually): most update fail when trying
  to make them on a Relation::Sequel instance. SQL compilation mechanism
  lacks the update rules implemented in various operators.

* Add support for optional type checking through Type#with_typecheck
  and Type#without_typecheck.

  Type checking is disabled by default, and only check for attribute
  presence, absence and no-clash policy on the various available
  operators.

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