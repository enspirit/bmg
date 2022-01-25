require 'spec_helper'
module Bmg
  module Operator
    describe Autosummarize do

      context 'with empty by and no sums' do
        let(:by)  { [] }
        let(:sums){ {} }

        it 'filters same tuples' do
          autosummarize = Autosummarize.new Type::ANY, [
            { a: 1 },
            { a: 1 }
          ], by, sums
          expect(autosummarize.to_a).to eql([{ a: 1 }])
        end
      end

      context 'with a determinant and no sums' do
        let(:by)  { [:a] }
        let(:sums){ {} }

        it 'applies Same to every unknown dependent' do
          autosummarize = Autosummarize.new Type::ANY, [
            { a: 1, b: 2 },
            { a: 1, b: 2 },
            { a: 2, b: 2 },
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { a: 1, b: 2 },
            { a: 2, b: 2 }
          ])
        end
      end

      context 'with a by and a DistinctList without comparator' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::DistinctList.new } }

        it 'groups as expected' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: 1 },
            { id: 1, a: 2 },
            { id: 2, a: 1 },
            { id: 1, a: 2 }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: [1, 2] },
            { id: 2, a: [1] },
          ])
        end

        it 'ignores nulls' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: 1   },
            { id: 1, a: nil }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: [1] },
          ])
        end

        it 'can be used to mimic the Group operator' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: { x: 1, y: 2 } },
            { id: 1, a: { x: 2, y: 2 } },
            { id: 2, a: { x: 1, y: 2 } },
            { id: 1, a: { x: 1, y: 2 } }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: [{ x: 1, y: 2 }, { x: 2, y: 2 }] },
            { id: 2, a: [{ x: 1, y: 2 }] },
          ])
        end

        it 'supports the :group shortcut' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: 1 },
            { id: 1, a: 2 },
            { id: 2, a: 1 },
            { id: 1, a: 2 }
          ], by, { :a => :group }
          expect(autosummarize.to_a).to eql([
            { id: 1, a: [1, 2] },
            { id: 2, a: [1] },
          ])
        end

      end

      context 'with a by and a DistinctList with a comparator' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::DistinctList.new{|x,y| y <=> x } } }

        it 'groups as expected' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: 1 },
            { id: 1, a: 2 },
            { id: 2, a: 1 },
            { id: 1, a: 2 }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: [2, 1] },
            { id: 2, a: [1] },
          ])
        end
      end

      context 'with a YByX ignoring nulls' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::YByX.new(:y, :x) } }

        it 'groups as expected and ignores nulls' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: { x: "foo", y: "bar" } },
            { id: 1, a: { x: "foo", y: "baz" } },
            { id: 1, a: { x: "gri", y: "gra" } },
            { id: 1, a: { x: "gro", y: nil   } },
            { id: 1, a: { x: nil,   y: "gru" } },
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { "foo" => "baz", "gri" => "gra" } }
          ])
        end

        it 'it supports nil tuples' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: nil },
            { id: 1, a: { x: "foo", y: "baz" } },
            { id: 1, a: nil }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { "foo" => "baz" } }
          ])
        end
      end

      context 'with a YByX preserving nulls' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::YByX.new(:y, :x, true) } }

        it 'groups as expected and ignores nulls' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: { x: "foo", y: "bar" } },
            { id: 1, a: { x: "foo", y: "baz" } },
            { id: 1, a: { x: "gri", y: "gra" } },
            { id: 1, a: { x: "gro", y: nil   } },
            { id: 1, a: { x: nil,   y: "gru" } },
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { "foo" => "baz", "gri" => "gra", "gro" => nil } }
          ])
        end
      end

      context 'with a by and a YsByX and no sorter' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::YsByX.new(:y, :x) } }

        it 'filters same tuples' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: { x: 1, y: 3 } },
            { id: 1, a: { x: 1, y: 2 } },
            { id: 2, a: { x: 1, y: 1 } },
            { id: 1, a: { x: 2, y: 7 } }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { 1 => [3, 2], 2 => [7] } },
            { id: 2, a: { 1 => [1] } }
          ])
        end

        it 'supports nil tuples' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: nil },
            { id: 1, a: { x: 1, y: 2 } },
            { id: 2, a: { x: 1, y: 1 } },
            { id: 1, a: nil }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { 1 => [2] } },
            { id: 2, a: { 1 => [1] } }
          ])
        end
      end

      context 'with a by and a YsByX and a sorter' do
        let(:by)  { [ :id ] }
        let(:sums){ { :a => Autosummarize::YsByX.new(:y, :x){|u,v| u[:y] <=> v[:y] } } }

        it 'filters same tuples' do
          autosummarize = Autosummarize.new Type::ANY, [
            { id: 1, a: { x: 1, y: 3 } },
            { id: 1, a: { x: 1, y: 2 } },
            { id: 2, a: { x: 1, y: 1 } },
            { id: 1, a: { x: 2, y: 7 } }
          ], by, sums
          expect(autosummarize.to_a).to eql([
            { id: 1, a: { 1 => [2, 3], 2 => [7] } },
            { id: 2, a: { 1 => [1] } }
          ])
        end
      end

      context 'when unsummed attributes are not functionnaly dependent of the key' do
        let(:by)  { [:a] }
        let(:sums){ {b: Autosummarize::DistinctList.new} }

        it 'raises an error' do
          autosummarize = Autosummarize.new Type::ANY, [
            { a: 1, b: 1, c: 1 },
            { a: 1, b: 1, c: 2 }
          ], [:a], sums
          expect{
            autosummarize.to_a
          }.to raise_error(TypeError)
        end

        it 'allows using a faster algorithm that takes the first value encountered' do
          autosummarize = Autosummarize.new Type::ANY, [
            { a: 1, b: 1, c: 1 },
            { a: 1, b: 1, c: 2 }
          ], [:a], sums, :default => :first
          expect(autosummarize.to_a).to eql([
            { a: 1, b: [1], c: 1 }
          ])
        end
      end

    end
  end
end
