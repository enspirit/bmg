# 0.3.0 - March 5st, 2018

* Add the Constants operator: extends the operand's tuple with attributes whose values are
  known statically. This is a special case of extension where values are not Proc but constants.

* Add the Image operator: extends the operand's tuple with the relational image on a right
  operand. Unlike Alf, the join attributes are explicit for now.

* Add the Restrict operator: restrict filters the operand tuples to those for which a predicate
  evaluates to true.

* Add the Union operator: union returns both the tuples from left and right operands, but
  strips the duplicates, if any.

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