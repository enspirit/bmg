require 'spec_helper'
module Bmg
  describe Relation do

    shared_examples_for "an operator method" do

      it 'returns a relation' do
        expect(subject).to be_a(Relation)
      end

      it 'supports calling count' do
        expect(subject.count).not_to be(nil)
      end

    end

    describe 'new' do

      it "accepts arrays but enclosed them as Leafs" do
        tuple = { a: 1, b: 2 }
        rel = Relation.new([tuple])
        expect(rel).to be_a(Relation::InMemory)
      end

    end

    describe 'one' do

      it "returns the only tuple of a singleton" do
        tuple = { a: 1, b: 2 }
        one = Relation.new([tuple]).one
        expect(one).to be(tuple)
      end

      it 'raises an exception if the relation is empty' do
        expect{
          Relation.new([]).one
        }.to raise_error(OneError, "Relation is empty")
      end

      it 'raises an exception if the relation has more than one tuple' do
        expect{
          Relation.new([{a: 1},{a: 2}]).one
        }.to raise_error(OneError, "Relation has more than one tuple")
      end

    end

    describe 'one_or_nil' do

      it "returns the only tuple of a singleton" do
        tuple = { a: 1, b: 2 }
        one = Relation.new([tuple]).one_or_nil
        expect(one).to be(tuple)
      end

      it 'returns nil if the relation is empty' do
        expect(Relation.new([]).one_or_nil).to be_nil
      end

      it 'raises an exception if the relation has more than one tuple' do
        expect{
          Relation.new([{a: 1},{a: 2}]).one_or_nil
        }.to raise_error(OneError, "Relation has more than one tuple")
      end

    end

    describe 'allbut' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.allbut([:b])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1 },
          { a: 3 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:allbut, [:in_memory, data], [:b]])
      end
    end

    describe 'autosummarize' do
      let(:data) {
        [
          { a: 1, x: 2 },
          { a: 1, x: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      let(:options) {
        { x: Operator::Autosummarize::DistinctList.new }
      }

      subject {
        relation.autosummarize([:a], options)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, x: [2, 4] }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:autosummarize, [:in_memory, data], [:a], options ])
      end
    end

    describe 'autowrap' do
      let(:data) {
        [
          { a: 1, b_x: 2, b_y: 3 },
          { a: 2, b_x: 4, b_y: 1 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      let(:options) {
        { split: "." }
      }

      subject {
        relation.autowrap
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: { x: 2, y: 3 } },
          { a: 2, b: { x: 4, y: 1 } }
        ])
      end

      it 'passes the options' do
        expect(relation.autowrap(options).to_a).to eql([
          { a: 1, b_x: 2, b_y: 3 },
          { a: 2, b_x: 4, b_y: 1 }
        ])
      end

      it 'has the expected ast' do
        expect(relation.autowrap(options).to_ast).to eql([:autowrap, [:in_memory, data], options ])
      end
    end

    describe 'constants' do
      let(:data) {
        [
          { a: 1, b: 1 },
          { a: 1, b: 2 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.constants(c: 3)
      }

      it_behaves_like "an operator method"

      it 'returns the expected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 1, c: 3 },
          { a: 1, b: 2, c: 3 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:constants, [:in_memory, data], {c: 3}])
      end
    end

    describe 'extend' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      let(:extension) {
        { c: ->(t){ t[:a] + t[:b] } }
      }

      subject {
        relation.extend(extension)
      }

      it_behaves_like "an operator method"

      it 'returns the expected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2, c: 3 },
          { a: 1, b: 4, c: 5 },
          { a: 3, b: 4, c: 7 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:extend, [:in_memory, data], extension])
      end
    end

    describe 'group' do
      let(:operand_data) {
        [
          { a: 1, b: 2 },
          { a: 2, b: 3 },
          { a: 1, b: 4 }
        ]
      }

      let(:operand) {
        Relation.new(operand_data)
      }

      subject{
        operand.group([:b], :grouped, array: true)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, grouped: [{b: 2}, {b: 4}]},
          { a: 2, grouped: [{b: 3}]},
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:group, [:in_memory, operand_data], [:b], :grouped, {array: true}])
      end
    end

    describe 'image' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.image(right, :image, [:a], array: true)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2, image: [{c: 4}, {c: 5}]},
          { a: 3, b: 4, image: []},
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:image,
          [:in_memory, left_data],
          [:in_memory, right_data],
          :image,
          [:a],
          {array: true, strategy: :refilter_right}])
      end
    end

    describe 'join' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 },
          { a: 7, c: 15 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.join(right, [:a])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2, c: 4 },
          { a: 1, b: 2, c: 5 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:join, [:in_memory, left_data], [:in_memory, right_data], [:a]])
      end
    end

    describe 'left_join' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 },
          { a: 7, c: 15 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.left_join(right, [:a], { c: 18 })
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2, c: 4 },
          { a: 1, b: 2, c: 5 },
          { a: 3, b: 4, c: 18 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:join, [:in_memory, left_data], [:in_memory, right_data], [:a], { variant: :left, default_right_tuple: { c: 18 } }])
      end
    end

    describe 'matching' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.matching(right, [:a])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:matching, [:in_memory, left_data], [:in_memory, right_data], [:a]])
      end
    end

    describe 'not_matching' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.not_matching(right, [:a])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 3, b: 4 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:not_matching, [:in_memory, left_data], [:in_memory, right_data], [:a]])
      end
    end

    describe 'page' do
      let(:data) {
        [
          { a: 1 },
          { a: 2 },
          { a: 3 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.page([:a], 2, page_size: 1)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 2 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([ :page, [:in_memory, data], [:a], 2, page_size: 1 ])
      end
    end

    describe 'project' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.project([:b])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { b: 2 },
          { b: 4 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([ :project, [:in_memory, data], [:b] ])
      end
    end

    describe 'rename' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 2, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.rename(b: :c)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, c: 2 },
          { a: 2, c: 4 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:rename, [:in_memory, data], {b: :c}])
      end
    end

    describe 'restrict' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 2, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.restrict(a: 1)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:restrict, [:in_memory, data], [:eq, [:identifier, :a], [:literal, 1]]])
      end

      it 'always optimizes restrictions on tautologies' do
        expect(relation.restrict(Predicate.tautology)).to be(relation)
      end

      it 'always optimizes restrictions on contradictions' do
        expect(relation.restrict(Predicate.contradiction)).to be_a(Relation::Empty)
      end
    end

    describe 'rxmatch' do
      let(:data) {
        [
          { a: "foo", b: 2 },
          { a: "bar", b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.rxmatch([:a, :b], /fo/)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: "foo", b: 2 },
        ])
      end
    end

    describe 'summarize' do
      let(:data) {
        [
          { a: 1, b: 2 },
          { a: 2, b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      subject {
        relation.summarize([], :a => :sum, :b => :collect, :c => :count)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 3, b: [2, 4], c: 2 }
        ])
      end
    end

    describe 'transform' do
      let(:data) {
        [
          { a: "foo", b: 2 },
          { a: "bar", b: 4 }
        ]
      }

      let(:relation) {
        Relation.new(data)
      }

      context 'when used with a single symbol' do
        subject {
          relation.transform(:to_s)
        }

        it_behaves_like "an operator method"

        it 'applies the transformation to all attributes' do
          expect(subject.to_a).to eql([
            { a: "foo", b: "2" },
            { a: "bar", b: "4" }
          ])
        end
      end

      context 'when used with an array of symbols' do
        subject {
          relation.transform([:to_s, :upcase])
        }

        it_behaves_like "an operator method"

        it 'applies the transformationS to all attributes' do
          expect(subject.to_a).to eql([
            { a: "FOO", b: "2" },
            { a: "BAR", b: "4" }
          ])
        end
      end

      context 'when used with an Hash' do
        subject {
          relation.transform(a: :upcase)
        }

        it_behaves_like "an operator method"

        it 'applies the transformation to specified attributes' do
          expect(subject.to_a).to eql([
            { a: "FOO", b: 2 },
            { a: "BAR", b: 4 }
          ])
        end
      end

      context 'when used with a Proc' do
        subject {
          relation.transform(&:to_s)
        }

        it_behaves_like "an operator method"

        it 'applies the transformation to all attributes' do
          expect(subject.to_a).to eql([
            { a: "foo", b: "2" },
            { a: "bar", b: "4" }
          ])
        end
      end
    end

    describe 'union' do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 2, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject {
        left.union(right)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2 },
          { a: 2, b: 4 },
          { a: 3, b: 4 }
        ])
      end

      it 'has the expected ast' do
        expect(subject.to_ast).to eql([:union, [:in_memory, left_data], [:in_memory, right_data], {all: false}])
      end
    end

    describe 'materialize' do
      let(:source) { Relation.new [] }

      it 'returns a materizalized relation' do
        expect(source.materialize).to be_a(Relation::Materialized)
        expect(operand(source.materialize)).to be(source)
      end
    end

  end # describe Relation
end # module Bmg
