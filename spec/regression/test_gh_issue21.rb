require 'spec_helper'
describe "Github issue 21" do

  class MemoryDb
    def initialize(typecheck = false)
      @typecheck = typecheck
    end

    def transactions
      r = Bmg::Relation.new([
        { id: 11, amount: 100, name: 'First Paycheck' },
        { id: 12, amount: 200, name: 'Second Paycheck' },
        { id: 13, amount: -100, name: 'Internet Bill' },
      ])
      if @typecheck
        r.with_type Bmg::Type::ANY.with_attrlist([:id, :amount, :name]).with_typecheck
      else
        r
      end
    end
    
    def tags
      r = Bmg::Relation.new([
        { id: 1, transaction_id: 11, name: 'income' },
        { id: 2, transaction_id: 12, name: 'income' },
        { id: 3, transaction_id: 13, name: 'bill' },
      ])
      if @typecheck
        r.with_type(Bmg::Type::ANY.with_attrlist([:id, :transaction_id, :name])).with_typecheck
      else
        r
      end
    end
  end

  class SqliteDb
    def db
      @db ||= begin
        (Path.dir/"gh_issue21.db").rm_rf
        Sequel.connect("sqlite://#{Path.dir}/gh_issue21.db")
      end
    end

    def install
      data = MemoryDb.new
      db.execute_ddl <<-SQL
        CREATE TABLE transactions (
          id INTEGER,
          amount INTEGER,
          name VARCHAR(50),
          PRIMARY KEY (id)
        );
        CREATE TABLE tags (
          id INTEGER,
          transaction_id INTEGER,
          name VARCHAR(50),
          PRIMARY KEY (id)
        );
      SQL
      db[:transactions].multi_insert(data.transactions.to_a)
      db[:tags].multi_insert(data.tags.to_a)
      self
    end

    def transactions
      Bmg.sequel(:transactions, db)
    end

    def tags
      Bmg.sequel(:tags, db)
    end
  end
  
  let(:expected){
    Bmg::Relation.new([
      { id: 11, name: "First Paycheck", amount: 100},
      { id: 12, name: "Second Paycheck", amount: 200}
    ])
  }

  shared_examples_for "A Github #21 candidate query" do
    context 'on MemoryDb' do
      let(:db) {
        MemoryDb.new
      }

      it 'returns expected result on in-memory database' do
        expect(subject.to_a.to_set).to eql(expected.to_a.to_set)
      end
    end

    context 'on SqliteDB' do
      let(:db) {
        SqliteDb.new.install
      }

      it 'returns expected result on sqlite database' do
        expect(subject.debug.to_a.to_set).to eql(expected.to_a.to_set)
      end
    end
  end

  shared_examples_for "A wrong query that is detected by type checking" do
    context 'on MemoryDb' do
      let(:db) {
        MemoryDb.new(true)
      }

      it 'returns expected result on in-memory database' do
        expect {
          subject.debug
        }.to raise_error(Bmg::TypeError)
      end
    end
  end

  describe 'the original query' do
    subject {
      of_interest = db.tags.restrict(name: 'income')
      db.transactions.join(of_interest, :id => :transaction_id)
    }

    it_behaves_like "A Github #21 candidate query"
    it_behaves_like "A wrong query that is detected by type checking"
  end

  describe 'the corrected query (following @amw-zero)' do
    subject {
      of_interest = db.tags.restrict(name: 'income').allbut([:id])
      db.transactions.join(of_interest, :id => :transaction_id)
    }

    it_behaves_like "A Github #21 candidate query"
  end

  describe 'the query using no syntactic sugar' do
    subject {
      of_interest = db.tags.restrict(name: 'income').allbut([:id]).rename(:transaction_id => :id)
      db.transactions.join(of_interest, [:id])
    }

    it_behaves_like "A Github #21 candidate query"
  end

  describe 'a matching approach' do
    subject {
      of_interest = db.tags.restrict(name: 'income').allbut([:id])
      db.transactions.matching(of_interest, :id => :transaction_id)
    }

    it_behaves_like "A Github #21 candidate query"
  end

end
