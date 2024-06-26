require 'spec_helper'
module Bmg
  class Summarizer
    describe Bucketize do

      def bucketizer(attr, opts)
        Bucketize.new(attr, options.merge(opts))
      end

      let(:options) {
        { }
      }

      context 'with distinct values' do
        let(:rel){[
          {:sid => 'S1', :qty => 10},
          {:sid => 'S2', :qty => 20},
          {:sid => 'S3', :qty => 30},
          {:sid => 'S4', :qty => 40}
        ]}

        context 'with separate boundaries' do
          let(:options) {
            { boundaries: :separate }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10..20, 30..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10..20, 30..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10..10, 20..20, 30..30, 40..40])
          end
        end

        context 'with touching boundaries' do
          let(:options) {
            { boundaries: :touching }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10...20, 20..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10...20, 20..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10...10, 10...20, 20...30, 30..40])
          end
        end
      end

      context 'with non distinct values' do
        let(:rel){[
          {:sid => 'S1', :qty => 10},
          {:sid => 'S2', :qty => 20},
          {:sid => 'S3', :qty => 30},
          {:sid => 'S4', :qty => 40},
          {:sid => 'S5', :qty => 40}
        ]}

        context 'with separate boundaries' do
          let(:options) {
            { boundaries: :separate }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10..30, 40..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10..20, 30..40, 40..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10..20, 30..40, 40..40])
          end

          it 'supports distinct' do
            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10..30, 40..40])

            got = bucketizer(:qty, :size => 2, :distinct => true).summarize(rel)
            expect(got).to eql([10..20, 30..40])
          end
        end

        context 'with touching boundaries' do
          let(:options) {
            { boundaries: :touching }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10...30, 30..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10...20, 20...40, 40..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10...20, 20...40, 40..40])
          end

          it 'supports distinct' do
            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10...30, 30..40])

            got = bucketizer(:qty, :size => 2, :distinct => true).summarize(rel)
            expect(got).to eql([10...20, 20..40])
          end
        end
      end

      context 'in presence of nil' do
        let(:rel){[
          {:sid => 'S1', :qty => 10},
          {:sid => 'S2', :qty => 20},
          {:sid => 'S3', :qty => 30},
          {:sid => 'S4', :qty => 40},
          {:sid => 'S5', :qty => nil},
        ]}

        context 'with separate boundaries' do
          let(:options) {
            { boundaries: :separate }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10..20, 30..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10..20, 30..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10..10, 20..20, 30..30, 40..40])
          end
        end

        context 'with touching boundaries' do
          let(:options) {
            { boundaries: :touching }
          }

          it 'should work when used standalone' do
            got = bucketizer(:qty, :size => 1).summarize(rel)
            expect(got).to eql([10..40])

            got = bucketizer(:qty, :size => 2).summarize(rel)
            expect(got).to eql([10...20, 20..40])

            got = bucketizer(:qty, :size => 3).summarize(rel)
            expect(got).to eql([10...20, 20..40])

            got = bucketizer(:qty, :size => 4).summarize(rel)
            expect(got).to eql([10...10, 10...20, 20...30, 30..40])
          end
        end
      end

      context 'with string values and touching boundaries' do
        let(:rel){
          ["Denver", "Austin", "Chicago", "Boston", "Dallas", "Atlanta", "Detroit", "Houston", "San Francisco", "Los Angeles", "New York", "Seattle", "Miami", "Phoenix", "Las Vegas"].map{|city|
            { :city => city }
          }
        }

        it 'should work as expected with touching' do
          got = bucketizer(:city, size: 5, boundaries: :touching).summarize(rel)
          expect(got).to eql(["Atlanta"..."Boston", "Boston"..."Denver", "Denver"..."Las Vegas", "Las Vegas"..."New York", "New York".."Seattle"])
        end

        it 'should work as expected with touching and value_length' do
          got = bucketizer(:city, size: 5, boundaries: :touching, value_length: 3).summarize(rel)
          expect(got).to eql(["Atl"..."Bos", "Bos"..."Den", "Den"..."Las", "Las"..."New", "New".."Sea"])
        end

        it 'should work as expected with separate' do
          got = bucketizer(:city, size: 5, boundaries: :separate).summarize(rel)
          expect(got).to eql(["Atlanta".."Boston", "Chicago".."Denver", "Detroit".."Las Vegas", "Los Angeles".."New York", "Phoenix".."Seattle"])
        end

        it 'should work as expected with separate and value_length' do
          got = bucketizer(:city, size: 5, boundaries: :separate, value_length: 3).summarize(rel)
          expect(got).to eql(["Atl".."Bos", "Chi".."Den", "Det".."Las", "Los".."New", "Pho".."Sea"])
        end
      end

      it 'should install factory methods' do
        s = Summarizer.bucketize(:qty, :distinct => true)
        expect(s).to be_a(Bucketize)
        expect(s.options[:distinct]).to eql(true)
      end

    end
  end
end
