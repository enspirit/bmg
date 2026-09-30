$LOAD_PATH.unshift(ENV['BMG_LIB'] || File.expand_path('../../lib', __FILE__))
require 'bmg'
require 'bmg/sequel'
require 'path'
require_relative 'bench_helper'

#
# Benchmarks the compiler, i.e. everything that happens between building a
# relational expression and getting the SQL out of it: type inference, the
# `_restrict`/`_project`/... push-down rules, and the sexpr rewriting done by
# Bmg::Sql::Processor.
#
# Nothing is executed against the database here; only `to_sql` is called.
#

DB = Sequel.connect("sqlite://#{Path.dir.parent}/spec/suppliers-and-parts.db")

def suppliers
  Bmg.sequel(:suppliers, DB, Bmg::Type::ANY
    .with_attrlist([:sid, :name, :city, :status])
    .with_keys([[:sid]]))
end

def parts
  Bmg.sequel(:parts, DB, Bmg::Type::ANY
    .with_attrlist([:pid, :name, :color, :weight, :city])
    .with_keys([[:pid]]))
end

def supplies
  Bmg.sequel(:supplies, DB, Bmg::Type::ANY
    .with_attrlist([:sid, :pid, :qty])
    .with_keys([[:sid, :pid]]))
end

BenchHelper.report("compiling a realistic query to SQL") do |x|
  x.report("join + restrict + project") do
    suppliers
      .restrict(Predicate.eq(city: 'London'))
      .join(supplies, [:sid])
      .join(parts.rename(name: :part_name), [:pid])
      .restrict(Predicate.gt(:qty, 100))
      .project([:sid, :name, :part_name, :qty])
      .to_sql
  end

  x.report("matching + union") do
    suppliers
      .matching(supplies.restrict(Predicate.gt(:qty, 100)), [:sid])
      .union(suppliers.restrict(Predicate.eq(status: 30)))
      .allbut([:status])
      .to_sql
  end

  x.report("summarize + page") do
    supplies
      .summarize([:sid], qty: :sum)
      .page([[:sid, :asc]], 2, page_size: 10)
      .to_sql
  end
end

# The push-down rules and the `clip` processor walk the whole attribute list
# of the relation, testing each attribute for membership in a (much smaller)
# projection/butlist. That is O(attributes x list) with arrays.
WIDE_ATTRS = (0...200).map{|i| :"a#{i}" }
WIDE_TYPE  = Bmg::Type::ANY.with_attrlist(WIDE_ATTRS).with_keys([[:a0]])

def wide
  Bmg.sequel(:wide, DB, WIDE_TYPE)
end

BenchHelper.report("compiling against a 200-attribute relation") do |x|
  x.report("project 5 of 200") { wide.project(WIDE_ATTRS.first(5)).to_sql }
  x.report("allbut 190 of 200") { wide.allbut(WIDE_ATTRS.last(190)).to_sql }
  x.report("autowrap + allbut") do
    Bmg.sequel(:wide, DB, Bmg::Type::ANY
      .with_attrlist(WIDE_ATTRS.map{|a| :"n_#{a}" }))
      .autowrap
      .allbut([:n])
      .to_sql
  end
end
