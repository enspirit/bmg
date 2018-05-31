require 'sql_helper'
module Bmg
  module Sql
    describe SelectList, "desaliaser" do

      context 'when for_predicate is false' do
        let(:expr){
          sexpr([
            :select_list,
            select_item("foo", "bar"),
            select_item("baz", "ban"),
            select_item(literal(23), "lit"),
          ])
        }

        subject{ expr.desaliaser }

        it 'returns what is expected' do
          d = subject
          expect(d["bar"]).to eql(qualified_name("t1", "foo"))
          expect(d["ban"]).to eql(qualified_name("t1", "baz"))
          expect(d["lit"]).to eql(literal(23))
        end
      end

      context 'when for_predicate is true' do
        let(:expr){
          sexpr([
            :select_list,
            select_item("foo", "bar"),
            select_item("baz", "ban"),
            select_item(literal(23), "lit"),
          ])
        }

        subject{ expr.desaliaser(true) }

        it 'returns what is expected' do
          d = subject
          expect(d["bar"]).to eql(Predicate::Grammar.sexpr([:qualified_identifier, :t1, :foo]))
          expect(d["ban"]).to eql(Predicate::Grammar.sexpr([:qualified_identifier, :t1, :baz]))
          expect(d["lit"]).to eql(Predicate::Grammar.sexpr([:literal, 23]))
        end
      end

    end
  end
end
