require 'spec_helper'
module Bmg
  describe Type do

    let(:type){ Type::ANY.with_attrlist([:id, :name]).with_typecheck }

    describe "with_typecheck" do

      let(:type){ Type::ANY }

      subject{
        type.with_typecheck
      }

      it 'returns the type itself, but with typecheck unabled' do
        expect(subject).to be_a(Type)
        expect(subject.typechecked?).to eql(true)
      end

    end

    describe Type, "without_typecheck" do

      let(:type){ Type::ANY.with_typecheck }

      subject{
        type.without_typecheck
      }

      it 'returns the type itself, but with typecheck disabled' do
        expect(subject).to be_a(Type)
        expect(subject.typechecked?).to eql(false)
      end

    end

    describe "allbut typecheck" do
      it 'detects allbutting unexisting attributes' do
        expect{
          type.allbut([:foo])
        }.to raise_error(Bmg::TypeError, /foo/)
      end
    end

    describe "autosummarize typecheck" do
      it 'detects unexisting attributes' do
        expect{
          type.autosummarize([:foo], :name => :group)
        }.to raise_error(Bmg::TypeError, /foo/)
        expect{
          type.autosummarize([:id], :name => :group, :foo => :nil)
        }.to raise_error(Bmg::TypeError, /foo/)
      end
    end

    describe "constants typecheck" do
      it 'detects erasing existing attributes' do
        expect{
          type.constants(:name => "Foo")
        }.to raise_error(Bmg::TypeError, /name/)
      end
    end

    describe "extend typecheck" do
      it 'detects erasing existing attributes' do
        expect{
          type.extend(:name => ->(t){ "Name" })
        }.to raise_error(Bmg::TypeError, /name/)
      end
    end

    describe "group typecheck" do
      it 'detects unexisting attributes' do
        expect{
          type.group([:foo], :bar)
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects clash with new attribute' do
        expect{
          type.group([:name], :id)
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "image typecheck" do
      it 'detects unexisting on attributes' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.image(right_type, :image, [:foo], {})
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects clash with new attribute' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.image(right_type, :id, [:name], {})
        }.to raise_error(Bmg::TypeError, /id/)
      end

      it 'detects missing attribute on right' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.image(right_type, :image, [:id], {})
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "join typecheck" do
      it 'detects unexisting on attributes' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.join(right_type, [:foo])
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects missing attribute on right' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.join(right_type, [:id])
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "matching typecheck" do
      it 'detects unexisting on attributes' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.matching(right_type, [:foo])
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects missing attribute on right' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.matching(right_type, [:id])
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "not_matching typecheck" do
      it 'detects unexisting on attributes' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.not_matching(right_type, [:foo])
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects missing attribute on right' do
        right_type = Type::ANY.with_attrlist([:name])
        expect{
          type.not_matching(right_type, [:id])
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "page typecheck" do
      it 'detects unexisting ordering attributes' do
        expect{
          type.page([:foo], 1, {page_size: 18})
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects unexisting ordering attributes with full ordering' do
        expect{
          type.page([[:foo, :asc]], 1, {page_size: 18})
        }.to raise_error(Bmg::TypeError, /foo/)
      end
    end

    describe "project typecheck" do
      it 'detects unexisting attributes' do
        expect{
          type.project([:id, :foo])
        }.to raise_error(Bmg::TypeError, /foo/)
      end
    end

    describe "rename typecheck" do
      it 'detects unexisting attributes' do
        expect{
          type.rename(:foo => :bar)
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects clashes with existing attributes' do
        expect{
          type.rename(:name => :id)
        }.to raise_error(Bmg::TypeError, /id/)
      end
    end

    describe "restrict typecheck" do
      it 'detects unexisting attributes' do
        expect{
          type.restrict(Predicate.eq(:foo, 2))
        }.to raise_error(Bmg::TypeError, /foo/)
      end
    end

    describe "union typecheck" do
      it 'detects union incompatible operands' do
        other = Type::ANY.with_attrlist([:id, :name, :foo])
        expect{
          type.union(other)
        }.to raise_error(Bmg::TypeError, /foo/)
      end

      it 'detects union incompatible operands II' do
        other = Type::ANY.with_attrlist([:id])
        expect{
          type.union(other)
        }.to raise_error(Bmg::TypeError, /name/)
      end
    end
  end
end
