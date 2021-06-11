require 'spec_helper'
module Bmg
  module Operator
    describe Ungroup do

      subject {
        Ungroup.new(Type::ANY.with_keys(keys), operand, attrlist)
      }

      context 'with a candidate key that does not use the attrlist' do
        let(:keys) {
          [[:id], [:id, :grouped]]
        }

        describe 'with a single attribute' do
          let(:attrlist) {
            [:grouped]
          }

          let(:operand) {
            Relation.new [
              { id: 1, :grouped => [{ foo: "Bar" }, {foo: "Baz"}] },
              { id: 2, :grouped => [{ foo: "Fuu" }] },
              { id: 3, :grouped => [] }
            ]
          }

          it 'works' do
            expected = [
              { id: 1, foo: "Bar" },
              { id: 1, foo: "Baz" },
              { id: 2, foo: "Fuu" },
            ]
            expect(subject.to_a).to eql(expected)
          end
        end

        describe 'with two attributes' do
          let(:attrlist) {
            [:grouped, :second]
          }

          let(:operand) {
            Relation.new [
              { id: 1, :grouped => [{ foo: "Bar" }, {foo: "Baz"}], :second => [{bar: "Baz"}, {bar: "Boz"}] },
              { id: 2, :grouped => [{ foo: "Fuu" }], :second => [{bar: "Buz"}] },
              { id: 3, :grouped => [], :second => [{bar: "Fuz"}] },
              { id: 4, :grouped => [], :second => nil },
              { id: 5, :grouped => [{ foo: "Bar" }], :second => nil },
              { id: 6, :grouped => nil, :second => [{bar: "Baz"}] },
              { id: 7, :grouped => nil, :second => nil }
            ]
          }

          it 'works' do
            expected = [
              { id: 1, foo: "Bar", bar: "Baz" },
              { id: 1, foo: "Bar", bar: "Boz" },
              { id: 1, foo: "Baz", bar: "Baz" },
              { id: 1, foo: "Baz", bar: "Boz" },
              { id: 2, foo: "Fuu", bar: "Buz" },
            ]
            expect(subject.to_a).to eql(expected)
          end
        end

        describe 'when yielding duplicates (key violation)' do
          let(:attrlist) {
            [:grouped]
          }

          let(:operand) {
            Relation.new [
              { id: 1, :grouped => [{ foo: "Bar" }, {foo: "Baz"}] },
              { id: 1, :grouped => [{ foo: "Bar" }] },
            ]
          }

          it 'yields them (because PRE is wrong, POST is wrong too)' do
            expected = [
              { id: 1, foo: "Bar" },
              { id: 1, foo: "Baz" },
              { id: 1, foo: "Bar" }
            ]
            expect(subject.to_a).to eql(expected)
          end
        end
      end

      context 'with no candidate key' do
        let(:keys) {
          nil
        }

        describe 'when yielding duplicates' do
          let(:attrlist) {
            [:grouped]
          }

          let(:operand) {
            Relation.new [
              { id: 1, :grouped => [{ foo: "Bar" }, {foo: "Baz"}] },
              { id: 1, :grouped => [{ foo: "Bar" }] },
            ]
          }

          it 'removes them' do
            expected = [
              { id: 1, foo: "Bar" },
              { id: 1, foo: "Baz" },
            ]
            expect(subject.to_a).to eql(expected)
          end
        end
      end

      context 'with only candidate keys using grouped' do
        let(:keys) {
          [[:id, :grouped]]
        }

        describe 'when yielding duplicates' do
          let(:attrlist) {
            [:grouped]
          }

          let(:operand) {
            Relation.new [
              { id: 1, :grouped => [{ foo: "Bar" }, {foo: "Baz"}] },
              { id: 1, :grouped => [{ foo: "Bar" }] },
            ]
          }

          it 'removes them' do
            expected = [
              { id: 1, foo: "Bar" },
              { id: 1, foo: "Baz" },
            ]
            expect(subject.to_a).to eql(expected)
          end
        end
      end

    end
  end
end
