require 'benchmark/ips'
require 'set'

#
# Shared helpers for the benchmarks found in this folder.
#
# Run one with `bundle exec ruby bench/<name>.rb`.
#
module BenchHelper

  FILLERS = 10

  # A wide, mostly-unique dataset, the typical result of a flat join:
  #
  #   { id: 0, x: 173, a0: "...", ..., a9: "..." }
  #
  # `:id` is unique, `:x` has `distinct` distinct values.
  def self.flat(size, distinct: [size / 10, 1].max, fillers: FILLERS)
    rng = Random.new(42)
    (0...size).map{|i|
      t = { id: i, x: rng.rand(distinct) }
      (0...fillers).each{|j| t[:"a#{j}"] = "v#{i}-#{j}" }
      t
    }
  end

  # A dataset with a low-cardinality determinant, suitable for grouping and
  # summarization:
  #
  #   { dept: 17, city: 3, emp: 0, name: "..." }
  def self.groupy(size, depts: 50, cities: 20)
    rng = Random.new(42)
    (0...size).map{|i|
      { dept: rng.rand(depts),
        city: rng.rand(cities),
        emp:  i,
        name: "employee-#{i}" }
    }
  end

  # `size` tuples, half of which are duplicates of the other half.
  def self.duplicated(size)
    (flat(size / 2) * 2).shuffle(random: Random.new(7))
  end

  def self.attrs(n)
    (0...n).map{|j| :"a#{j}" }
  end

  # Forces a full iteration of `relation`. `Relation#count` is NOT usable for
  # that: several operators (image, extend, autosummarize) answer it by
  # delegating to their operand, without iterating anything.
  def self.drain(relation)
    n = 0
    relation.each{ n += 1 }
    n
  end

  def self.report(title, &bl)
    puts
    puts "=" * 72
    puts "#{title}  [ruby #{RUBY_VERSION}]"
    puts "=" * 72
    ENV['BENCH_MODE'] == 'cpu' ? cpu_report(&bl) : ips_report(&bl)
  end

  def self.ips_report(&bl)
    Benchmark.ips do |x|
      x.config(time: Float(ENV.fetch('BENCH_TIME', 5)),
               warmup: Float(ENV.fetch('BENCH_WARMUP', 2)))
      bl.call(x)
      x.compare!
    end
  end

  #
  # Reports CPU time per iteration rather than wall-clock throughput.
  #
  # Wall-clock throughput is only meaningful on an idle machine: anything
  # else competing for the cores shows up as a slowdown of whatever is being
  # measured. CLOCK_PROCESS_CPUTIME_ID counts only the cycles this process
  # actually got, which makes before/after comparisons usable on a busy
  # laptop. It still includes GC, which is real work.
  #
  # Reported as the median of `samples` runs, with the min/max spread, so a
  # comparison that falls inside the spread can be recognized as noise.
  #
  def self.cpu_report
    collector = CpuCollector.new(Integer(ENV.fetch('BENCH_SAMPLES', 7)))
    yield collector
    collector.print
  end

  class CpuCollector
    def initialize(samples)
      @samples = samples
      @results = {}
    end

    def report(name, &bl)
      iterations = calibrate(&bl)
      GC.start
      timings = (0...@samples).map{ time_of(iterations, &bl) }.sort
      @results[name] = [ timings[timings.size / 2], timings.first, timings.last ]
    end

    def print
      width = @results.keys.map(&:size).max
      Kernel.puts "%-#{width}s %14s %10s" % ["benchmark", "median us/i", "spread"]
      @results.each do |name, (med, min, max)|
        spread = (max - min) / med * 100
        Kernel.puts "%-#{width}s %14.2f %9.0f%%" % [name, med * 1e6, spread]
      end
    end

  private

    # Picks an iteration count giving runs of roughly 200ms of CPU time,
    # so that clock resolution and one-off effects stay negligible.
    def calibrate(&bl)
      n = 1
      loop do
        elapsed = time_of(n, &bl) * n
        return [(n * 0.2 / elapsed).ceil, 1].max if elapsed > 0.02
        n *= 4
      end
    end

    def time_of(iterations)
      t0 = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
      iterations.times{ yield }
      (Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - t0) / iterations
    end
  end

end
