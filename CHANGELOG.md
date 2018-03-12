# 0.5.0 - TBD

* Optimization: push restrictions over autosummarize, rename & restrict.

* Added Relation#to_json

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