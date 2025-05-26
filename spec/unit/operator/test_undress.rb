require 'spec_helper'
module Bmg
  module Operator
    describe Undress do

      it 'works on an empty Relation' do
        got = Relation.empty.undress
        expect(got.to_set).to eql(Relation.empty.to_set)
      end

      it 'works on an singleton with nothing to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg" },
        ])
        expect(rel.undress.to_set).to eql(rel.to_set)
      end

      it 'works on an singleton with a Date to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg", date: Date.parse('2025-01-17') },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", date: '2025-01-17' },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with a Time to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg", time: Time.parse('2025-01-17T09:00:00+01:00') },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", time: '2025-01-17T09:00:00+01:00' },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with a DateTime to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg", datetime: DateTime.parse('2025-01-17T09:00:00+01:00') },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", datetime: '2025-01-17T09:00:00+01:00' },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with an undressable' do
        undressable = Object.new
        def undressable.undress
          "2025-01-17"
        end
        rel = Relation.new([
          { id: 1, name: "Bmg", date: undressable },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", date: '2025-01-17' },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with a [Date] to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg", dates: [Date.parse('2025-01-17')] },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", dates: ['2025-01-17'] },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with a { x: Date } to undress' do
        rel = Relation.new([
          { id: 1, name: "Bmg", at: { date: Date.parse('2025-01-17') } },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", at: { date: '2025-01-17' } },
        ])
        expect(rel.undress.to_set).to eql(expected.to_set)
      end

      it 'works on an singleton with a RVA' do
        rel = Relation.new([
          { id: 1, name: "Bmg", dates: Bmg::Relation.new([{ at: Date.parse('2025-01-17') }]) },
        ])
        expected = Relation.new([
          { id: 1, name: "Bmg", dates: Bmg::Relation.new([{ at: '2025-01-17' }]) },
        ])
        expect(rel.undress.one[:dates].to_set).to eql(expected.one[:dates].to_set)
      end

    end
  end
end
