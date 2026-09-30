$LOAD_PATH.unshift(ENV['BMG_LIB'] || File.expand_path('../../lib', __FILE__))
require_relative 'bench_helper'

#
# Micro benchmarks isolating the three Array-vs-Set decisions that show up in
# bmg's in-memory operators:
#
#   1. membership tests against an attribute list (TupleAlgebra#project/#allbut,
#      Project#tuple_project, Allbut#tuple_allbut, ...)
#   2. "have I already seen this tuple?" accumulators (Project, Allbut, Union,
#      Matching, NotMatching, Ungroup)
#   3. building a distinct list incrementally (Autosummarize::YsByX)
#
# The point of having them here is that the answer is not the same on every
# ruby: Set is a plain-ruby wrapper around Hash up to 3.4, and a core class
# written in C as of 4.0.
#

TUPLE = BenchHelper.flat(1).first

## 1. membership ############################################################

[1, 3, 8, 24].each do |n|
  attrs     = BenchHelper.attrs(n)
  attrs_set = attrs.to_set
  attrs_hsh = attrs.each_with_object({}){|a,h| h[a] = true }

  BenchHelper.report("project a #{TUPLE.size}-attribute tuple on #{n} attributes") do |x|
    x.report("Array#include?") { TUPLE.reject{|k,_| !attrs.include?(k) } }
    x.report("Set#include?")   { TUPLE.reject{|k,_| !attrs_set.include?(k) } }
    x.report("Hash#key?")      { TUPLE.reject{|k,_| !attrs_hsh.key?(k) } }
  end
end

## 2. seen-accumulators #####################################################

SEEN_TUPLES = BenchHelper.duplicated(5_000)

BenchHelper.report("dedup 5000 tuples (50% duplicates)") do |x|
  x.report("Hash as set") do
    seen = {}
    SEEN_TUPLES.each do |t|
      next if seen.has_key?(t)
      seen[t] = true
    end
    seen.size
  end
  x.report("Set#add?") do
    seen = Set.new
    SEEN_TUPLES.each do |t|
      seen.add?(t)
    end
    seen.size
  end
  x.report("Set#include?/add") do
    seen = Set.new
    SEEN_TUPLES.each do |t|
      next if seen.include?(t)
      seen << t
    end
    seen.size
  end
end

## 3. incremental distinct list #############################################

VALUES = (0...2_000).map{|i| i % 200 }

BenchHelper.report("build a distinct list of 2000 values (200 distinct)") do |x|
  x.report("Array + uniq! per add") do
    a = []
    VALUES.each{|v| a << v; a.uniq! }
    a
  end
  x.report("Array + uniq at end") do
    a = []
    VALUES.each{|v| a << v }
    a.uniq
  end
  x.report("Set + to_a at end") do
    s = Set.new
    VALUES.each{|v| s << v }
    s.to_a
  end
end

## 4. set construction cost #################################################
#
# Memoizing `on.to_set` is only worth it if building the Set is cheap relative
# to the lookups it saves.

ON = BenchHelper.attrs(3)

BenchHelper.report("cost of building a 3-element Set") do |x|
  x.report("Array#to_set") { ON.to_set }
  x.report("Set.new")      { Set.new(ON) }
  x.report("Array#dup")    { ON.dup }
end
