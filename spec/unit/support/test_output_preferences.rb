require 'spec_helper'
module Bmg
  describe OutputPreferences do
    describe "tuple_ordering" do
      subject{
        OutputPreferences.new(options).tuple_ordering
      }

      context 'with no tuple ordering' do
        let(:options){{
        }}

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'with some tuple ordering' do
        let(:options){{
          tuple_ordering: [[:name, :desc]]
        }}

        it 'returns an Ordering instance' do
          expect(subject).to be_a(Bmg::Ordering)
        end
      end
    end
    describe "erase_redundance_in_group" do
      subject {
        OutputPreferences.new(options).erase_redundance_in_group(before, current)
      }

      context 'with no group attributes' do
        let(:options){{
        }}
        let(:before){ nil }
        let(:current){ { :name => "Bernard" } }

        it 'returns the current itself' do
          expect(subject.first).to be(nil)
          expect(subject.last).to be(current)
        end
      end

      context 'with some group attributes' do
        let(:options){{
           grouping_attributes: [:name, :reference]
        }}

        context "when no before" do
          let(:before){ nil }
          let(:current){ { :name => "Bernard", :reference => "foo" } }

          it 'returns the current itself' do
            expect(subject.first).to be(current)
            expect(subject.last).to be(current)
          end
        end

        context "when a different before" do
          let(:before){ { :name => "Yoann", :reference => "bar" } }
          let(:current){ { :name => "Bernard", :reference => "foo" } }

          it 'returns the current itself' do
            expect(subject.first).to eql(current)
            expect(subject.last).to eql(current)
          end
        end

        context "within same full group" do
          let(:before){ { :name => "Yoann", :reference => "bar", :extra => 1 } }
          let(:current){ { :name => "Yoann", :reference => "bar", :extra => 2 } }

          it 'returns the current itself' do
            expect(subject.first).to eql(current)
            expect(subject.last).to eql({ :name => nil, :reference => nil, :extra => 2 })
          end
        end

        context "within same first group" do
          let(:before){ { :name => "Yoann", :reference => "bar", :extra => 1 } }
          let(:current){ { :name => "Yoann", :reference => "foo", :extra => 2 } }

          it 'returns the current itself' do
            expect(subject.first).to eql(current)
            expect(subject.last).to eql({ :name => nil, :reference => "foo", :extra => 2 })
          end
        end

        context "within same second group but not first" do
          let(:before){ { :name => "Yoann", :reference => "bar", :extra => 1 } }
          let(:current){ { :name => "Bernard", :reference => "bar", :extra => 2 } }

          it 'returns the current itself' do
            expect(subject.first).to eql(current)
            expect(subject.last).to eql({ :name => "Bernard", :reference => "bar", :extra => 2 })
          end
        end
      end
    end
    describe "order_attrlist" do

      subject{
        OutputPreferences.new(options).order_attrlist(list)
      }

      context 'with no attribute ordering' do
        let(:options){{
        }}
        let(:list){
          [:firstname, :id, :lastname]
        }

        it 'returns the list itself' do
          expect(subject).to be(list)
        end
      end

      context 'with a full list' do
        let(:options){{
          attributes_ordering: [:id, :firstname, :lastname]
        }}
        let(:list){
          [:firstname, :id, :lastname]
        }

        it 'returns an ordered list' do
          expect(subject).to eql([:id, :firstname, :lastname])
        end
      end

      context 'with a partial list and extra attributes after the others' do
        let(:options){{
          attributes_ordering: [:firstname, :lastname],
          extra_attributes: :after
        }}
        let(:list){
          [:id, :lastname, :firstname]
        }

        it 'returns an ordered list' do
          expect(subject).to eql([:firstname, :lastname, :id])
        end
      end

      context 'with a partial list and extra attributes before the others' do
        let(:options){{
          attributes_ordering: [:firstname, :lastname],
          extra_attributes: :before
        }}
        let(:list){
          [:id, :lastname, :firstname]
        }

        it 'returns an ordered list' do
          expect(subject).to eql([:id, :firstname, :lastname])
        end
      end

      context 'with a partial list and extra attributes ignored' do
        let(:options){{
          attributes_ordering: [:firstname, :lastname],
          extra_attributes: :ignored
        }}
        let(:list){
          [:id, :lastname, :firstname]
        }

        it 'returns an ordered list' do
          expect(subject).to eql([:firstname, :lastname])
        end
      end
    end
  end
end
