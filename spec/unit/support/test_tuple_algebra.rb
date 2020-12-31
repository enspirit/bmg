require 'spec_helper'
module Bmg
  describe TupleAlgebra, "allbut" do
    include TupleAlgebra

    it 'works' do
      expect(allbut({a: 1, b: 2}, [:b])).to eql({a: 1})
    end

    it 'ignores unexisting attributes' do
      expect(allbut({a: 1, b: 2}, [:b, :c])).to eql({a: 1})
    end

    it 'does not change the original' do
      original = {a: 1, b: 2}
      expect(allbut(original, [:b])).to eql({a: 1})
      expect(original).to eql({a: 1, b: 2})
    end

  end
  describe TupleAlgebra, "project" do
    include TupleAlgebra

    it 'works' do
      expect(project({a: 1, b: 2}, [:a])).to eql({a: 1})
    end

    it 'ignores unexisting attributes' do
      expect(project({a: 1, b: 2}, [:a, :c])).to eql({a: 1})
    end

    it 'does not change the original' do
      original = {a: 1, b: 2}
      expect(project(original, [:a])).to eql({a: 1})
      expect(original).to eql({a: 1, b: 2})
    end

  end
  describe TupleAlgebra, "rename" do
    include TupleAlgebra

    it 'works' do
      expect(rename({a: 1, b: 2}, :a => :z)).to eql({z: 1, b: 2})
    end

    it 'ignores unexisting attributes' do
      expect(rename({a: 1, b: 2}, :a => :z, :c => :y)).to eql({z: 1, b: 2})
    end

    it 'does not change the original' do
      original = {a: 1, b: 2}
      expect(rename(original, :a => :z)).to eql({z: 1, b: 2})
      expect(original).to eql({a: 1, b: 2})
    end

  end
  describe TupleAlgebra, "symbolize_keys" do
    include TupleAlgebra

    it 'works' do
      expect(symbolize_keys({"a" => 1, "b" => 2})).to eql({a: 1, b: 2})
    end

    it 'works on empty' do
      h = {}
      expect(symbolize_keys(h)).to be(h)
    end

  end
end
