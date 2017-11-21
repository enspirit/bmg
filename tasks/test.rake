namespace :test do
  require "rspec/core/rake_task"

  tests = []

  desc "Runs unit tests on the library itself"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/test_*.rb"
    t.rspec_opts = ["-Ilib", "-Ispec/unit", "--color", "--backtrace", "--format=progress"]
  end
  tests << :unit

  task :all => tests
end

desc "Runs all tests, unit then integration on examples"
task :test => :'test:all'
