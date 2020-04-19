require 'spec_helper'
module Bmg
  module Operator
    describe Image, "jit_optimize" do

      class Image
        public :left, :right, :on, :as, :options
      end

      class Restrict
        public :operand, :predicate
      end

      class Allbut
        public :operand, :butlist
      end

      let(:rel) {
        Image.new(Type::ANY, left_rel, right_rel, :values, on, options.merge(array: true))
      }

      subject {
        rel.send(:jit_optimize)
      }

      let(:on){ [:id] }

      let(:left) {
        Relation.new([
          { id: 1, x: "foo" },
          { id: 2, x: "bar" }
        ])
      }
      let(:left_rel){ left }

      let(:right) {
        Relation.new([
          { id: 1, x: "foo", y: "hello" },
          { id: 1, x: "bar", y: "world" }
        ])
      }
      let(:right_rel){ right }

      after do
        expected = left_rel.image(right_rel, :values, on, { strategy: :index_right }.merge(array: true))
        expect(subject.to_a).to eql(expected.to_a)
      end

      context 'with :index_right strategy' do
        let(:options){ {strategy: :index_right} }
        let(:on){ [:id] }

        it 'does not touch the operands, and strips the strategy' do
          expect(subject.left).to be(rel.left)
          expect(subject.right).to be(rel.right)
          expect(subject.on).to eql(rel.on)
          expect(subject.as).to be(rel.as)
          expect(subject.options[:strategy]).to eql(:index_right)
        end
      end

      context 'with :refilter_right strategy' do
        let(:options){ {strategy: :refilter_right} }

        context 'with more than one `on` attribute, unoptimizable' do
          let(:on){ [:id, :x] }

          it 'does not touch the operands, and strips the strategy' do
            expect(subject.left).to be(rel.left)
            expect(subject.right).to be(rel.right)
            expect(subject.on).to eql(rel.on)
            expect(subject.as).to be(rel.as)
            expect(subject.options[:strategy]).to eql(:index_right)
          end
        end

        context 'with a single `on` attribute' do
          let(:on){ [:id] }

          before do
            def left.materialize
              Relation::Materialized.new(self)
            end
          end

          it 'refilters right through a materialization of left' do
            expect(subject.left).to be_a(Relation::Materialized)
            expect(subject.right).to be_a(Restrict)
            expect(subject.right.predicate.expr).to be_a(Predicate::In)
            expect(subject.right.operand).to be(right)
          end
        end

        context 'with a double `on` attribute, while one can be striped' do
          let(:on){ [:id, :x] }

          before do
            def left.materialize
              Relation::Materialized.new(self)
            end
          end

          let(:left_rel) {
            left.restrict(:x => "foo")
          }

          let(:right_rel) {
            right.restrict(:x => "foo")
          }

          it 'refilters right through a materialization of left' do
            expect(subject.left).to be_a(Relation::Materialized)
            expect(subject.right).to be_a(Allbut)
            expect(subject.right.butlist).to eql([:x])
            expect(subject.right.operand).to be_a(Restrict)
            expect(subject.right.operand.predicate.expr).to be_a(Predicate::And)
            expect(subject.right.operand.operand).to be(right)
            expect(subject.on).to eql([:id])
          end
        end

        context 'with a double `on` attribute, while all can be striped' do
          let(:on){ [:id, :x] }

          before do
            def left.materialize
              Relation::Materialized.new(self)
            end
          end

          let(:left_rel) {
            left.restrict(:id => 1, :x => "foo")
          }

          let(:right_rel) {
            right.restrict(:id => 1, :x => "foo")
          }

          it 'refilters right through a materialization of left' do
            expect(subject.left).to be(left_rel)
            expect(subject.right).to be_a(Allbut)
            expect(subject.right.butlist).to eql([:id, :x])
            expect(subject.right.operand).to be(right_rel)
            expect(subject.on).to eql([])
          end
        end

        context 'with a double `on` attribute, while all can be striped (from top)' do
          let(:on){ [:id, :x] }

          before do
            def left.materialize
              Relation::Materialized.new(self)
            end
          end

          it 'refilters right through a materialization of left' do
            s = subject.restrict(:id => 1, :x => "foo")
            expect(s.left).to be_a(Restrict)
            expect(s.right).to be_a(Restrict)
            expect(s.on).to eql([:id, :x])
          end
        end
      end

    end
  end
end
