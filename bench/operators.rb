$LOAD_PATH.unshift(ENV['BMG_LIB'] || File.expand_path('../../lib', __FILE__))
require 'bmg'
require_relative 'bench_helper'

#
# End-to-end benchmark of the in-memory (i.e. NOT compiled to SQL) operators.
#
# Unlike `set_vs_array.rb`, this one measures bmg itself, so it is meant to be
# run before and after a change, on every supported ruby:
#
#   for v in 3.4.1 4.0.7; do
#     RBENV_VERSION=$v bundle exec ruby bench/operators.rb | tee /tmp/bench-$v.txt
#   done
#

N = Integer(ENV.fetch('BENCH_N', 10_000))

drain = BenchHelper.method(:drain)

FLAT    = Bmg.in_memory(BenchHelper.flat(N))
SMALL   = Bmg.in_memory(BenchHelper.flat(N / 10, distinct: N / 10, fillers: 2))
DUPPY   = Bmg.in_memory(BenchHelper.duplicated(N))
SUBSET  = Bmg.in_memory(BenchHelper.flat(N / 2).first(N / 10))
GROUPY  = Bmg.in_memory(BenchHelper.groupy(N))
GROUPED = Bmg.in_memory(GROUPY.group([:emp, :name], :emps).to_a)

KEEP = [:id, :x, :a0]
DROP = BenchHelper.attrs(8)

BenchHelper.report("projection-like operators, #{N} tuples of 12 attributes") do |x|
  x.report("project (3 of 12)") { drain.(FLAT.project(KEEP)) }
  x.report("allbut (8 of 12)")  { drain.(FLAT.allbut(DROP)) }
end

BenchHelper.report("binary operators, #{N} x #{N / 10} tuples") do |x|
  x.report("join on :x")         { drain.(FLAT.join(SMALL.project([:x, :a0]), [:x])) }
  x.report("matching on :x")     { drain.(FLAT.matching(SMALL, [:x])) }
  x.report("not_matching on :x") { drain.(FLAT.not_matching(SMALL, [:x])) }
  x.report("image on :x")        { drain.(FLAT.image(SMALL, :img, [:x])) }
end

# The operators above all join on a single attribute, which is the common
# case. These ones use a wide key instead: membership in the key list is
# then worth indexing.
WIDE_ON = [:x] + BenchHelper.attrs(5)

BenchHelper.report("operators keyed on #{WIDE_ON.size} attributes") do |x|
  x.report("join")      { drain.(FLAT.join(FLAT.project(WIDE_ON), WIDE_ON)) }
  x.report("matching")  { drain.(FLAT.matching(FLAT.project(WIDE_ON), WIDE_ON)) }
  x.report("summarize") { drain.(FLAT.summarize(WIDE_ON, id: :count)) }
  x.report("group")     { drain.(FLAT.group(BenchHelper.attrs(6), :sub)) }
end

BenchHelper.report("grouping operators, #{N} tuples over 50 departments") do |x|
  x.report("group")     { drain.(GROUPY.group([:emp, :name], :emps)) }
  x.report("ungroup")   { drain.(GROUPED.ungroup([:emps])) }
  x.report("summarize") { drain.(GROUPY.summarize([:dept, :city], emp: :count)) }
end

# A flat join result where `:item` holds a nested tuple, the shape
# Autosummarize is meant for.
NESTED = Bmg.in_memory(BenchHelper.groupy(N).map{|t|
  { dept: t[:dept], item: { x: t[:city], y: t[:emp] % 40 } }
})

BenchHelper.report("autosummarize, #{N} tuples over 50 departments") do |x|
  x.report(":group (distinct list)") do
    drain.(NESTED.autosummarize([:dept], item: :group))
  end
  x.report("ys_by_x") do
    drain.(NESTED.autosummarize([:dept],
      item: Bmg::Operator::Autosummarize.ys_by_x(:y, :x)))
  end
end

# ys_by_x builds a distinct list per observed `x`. Its cost is driven by how
# many distinct `y` each of those lists ends up holding, so it deserves a
# case where that number is large.
WIDE_NESTED = Bmg.in_memory((0...N).map{|i|
  { dept: i % 4, item: { x: i % 8, y: i } }
})

BenchHelper.report("autosummarize ys_by_x, #{N / 32} distinct values per list") do |x|
  x.report("ys_by_x (wide lists)") do
    drain.(WIDE_NESTED.autosummarize([:dept],
      item: Bmg::Operator::Autosummarize.ys_by_x(:y, :x)))
  end
end

BenchHelper.report("set operators, #{N} tuples (50% duplicates)") do |x|
  x.report("union") { drain.(DUPPY.union(DUPPY)) }
  x.report("minus") { drain.(DUPPY.minus(SUBSET)) }
end
