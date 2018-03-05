# 0.3.0 - March 5st, 2018

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