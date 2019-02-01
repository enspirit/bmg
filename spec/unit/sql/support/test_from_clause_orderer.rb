require 'sql_helper'
module Bmg
  module Sql
    module Support
      describe FromClauseOrderer do

        subject{
          FromClauseOrderer.new.call(expr)
        }

        def collect
          FromClauseOrderer.new.send(:collect, expr)
        end

        def on(t1, a1, t2, a2)
          left_attr = qualified_name(t1, a1)
          right_attr = qualified_name(t2, a2)
          Predicate::Factory.eq(left_attr, right_attr)
        end

        def conjunction(left, right)
          Predicate::Factory.and(left, right)
        end

        context 'on a single table from clause' do
          let(:expr){
            sexpr [ :from_clause,
              table_as("t1")
            ]
          }
          let(:expected) {
            [
              [ :base, table_as("t1"), nil ]
            ]
          }

          it 'works as expected' do
            expect(subject).to eql(expected)
          end
        end

        context 'on a simple cross join' do
          let(:expr){
            sexpr [ :from_clause,
              cross_join(
                table_as("t1"),
                table_as("t2"))
            ]
          }
          let(:expected) {
            [
              [ :base,       table_as("t1"), nil ],
              [ :cross_join, table_as("t2"), nil ]
            ]
          }

          it 'works as expected' do
            expect(subject).to eql(expected)
          end
        end

        context 'on a simple inner join' do
          let(:expr){
            sexpr [ :from_clause,
              inner_join(
                table_as("t1"),
                table_as("t2"),
                on("t1","attr","t2","attr"))
            ]
          }
          let(:expected) {
            [
              [ :base,       table_as("t1"), nil ],
              [ :inner_join, table_as("t2"), on("t1","attr","t2","attr") ]
            ]
          }

          it 'works as expected' do
            expect(subject).to eql(expected)
          end
        end

        context 'on a typical inner join (regression)' do
          let(:expr){
            sexpr [ :from_clause,
              [ :inner_join,
                  [:table_as, [:table_name, :suppliers], [:range_var_name, "t1"]],
                  [:table_as, [:table_name, :supplies], [:range_var_name, "t2"]],
                  [:eq, [:qualified_identifier, :t1, :sid], [:qualified_identifier, :t2, :sid]]]]
          }

          let(:expected){
            [
              [:base,
                [:table_as, [:table_name, :suppliers], [:range_var_name, "t1"]],
                nil],
              [:inner_join,
                [:table_as, [:table_name, :supplies], [:range_var_name, "t2"]],
                [:eq, [:qualified_identifier, :t1, :sid], [:qualified_identifier, :t2, :sid]]]
            ]
          }

          it 'works as expected' do
            expect(subject).to eql(expected)
          end
        end

        context 'on a complex case join' do
          let(:expr){
            sexpr [ :from_clause,
              cross_join(
                inner_join(
                  table_as("t1"),
                  cross_join(
                    table_as("t3"),
                    table_as("t4")),
                  conjunction(
                    on("t1", "foo", "t3", "foo"),
                    on("t1", "bar", "t4", "baz"))
                ),
                table_as("t2")
              )
            ]
          }
          let(:expected) {
            [
              [ :base,       table_as("t2"), nil ],
              [ :cross_join, table_as("t1"), nil ],
              [ :inner_join, table_as("t3"), on("t1", "foo", "t3", "foo") ],
              [ :inner_join, table_as("t4"), on("t1", "bar", "t4", "baz") ]
            ]
          }

          it 'works as expected' do
            expect(subject).to eql(expected)
          end
        end

      end
    end
  end
end
