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