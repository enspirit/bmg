require 'rspec'
require 'bmg'
require 'bmg/sequel'
require 'path'

module SpecHelper
  SEQUEL_DB = Sequel.connect("sqlite://#{Path.dir.parent}/suppliers-and-parts.db")


  shared_examples_for "a Relation-compatible" do

    it 'is a relation' do
      expect(subject).to be_a(Bmg::Relation)
    end

    it 'each without block returns an Enumerator' do
      expect(subject.each).to be_a(Enumerator)
    end

    it 'supports calling count' do
      expect(subject.count).not_to be(nil)
    end

  end

  def sequel_db
    SEQUEL_DB
  end

  def operand(of = subject)
    of.send(:operand)
  end

  def left_operand(of = subject)
    of.send(:left)
  end

  def right_operand(of = subject)
    of.send(:right)
  end

  def operands(of = subject)
    of.send(:operands)
  end

  def options(of = subject)
    of.send(:options)
  end

  def predicate_of(of = subject)
    of.send(:predicate)
  end

end

RSpec.configure do |c|
  c.include SpecHelper
end
