require 'spec_helper'

# A left join keeps the left tuples that match nothing on the right. When the
# right operand carries a restriction of its own and the whole expression is
# compiled to a single SQL query, that restriction must stay with the right
# operand and not reach the WHERE of the result, where it would also have to
# hold of the tuples the left join just filled with nulls -- which makes the
# query an inner join and loses them.
#
# The in-memory relation is the reference: both must answer the same thing.
describe "A left join whose right operand is restricted" do

  LEFT_JOIN_GRANTS = [
    { family: 'F1', grantor: 'u1' },
    { family: 'F2', grantor: 'u2' },
  ]

  # `u2` is no longer a member, so the grant of theirs matches nothing once the
  # right operand is restricted -- and is precisely the tuple at stake.
  LEFT_JOIN_MEMBERS = [
    { user: 'u1', nickname: 'alice', state: 'active' },
    { user: 'u2', nickname: 'bob',   state: 'gone'   },
  ]

  class LeftJoinMemoryDb
    def grants
      Bmg::Relation.new(LEFT_JOIN_GRANTS)
    end

    def members
      Bmg::Relation.new(LEFT_JOIN_MEMBERS)
    end
  end

  class LeftJoinSqliteDb
    def db
      @db ||= begin
        (Path.dir/"left_join_restricted_right.db").rm_rf
        Sequel.connect("sqlite://#{Path.dir}/left_join_restricted_right.db")
      end
    end

    def install
      db.execute_ddl <<-SQL
        CREATE TABLE grants (
          family VARCHAR(50),
          grantor VARCHAR(50),
          PRIMARY KEY (family)
        );
        CREATE TABLE members (
          user VARCHAR(50),
          nickname VARCHAR(50),
          state VARCHAR(50),
          PRIMARY KEY (user)
        );
      SQL
      db[:grants].multi_insert(LEFT_JOIN_GRANTS)
      db[:members].multi_insert(LEFT_JOIN_MEMBERS)
      self
    end

    def grants
      Bmg.sequel(:grants, db)
    end

    def members
      Bmg.sequel(:members, db)
    end
  end

  let(:expected) {
    [
      { family: 'F1', grantor: 'u1', nickname: 'alice' },
      { family: 'F2', grantor: 'u2', nickname: '(none)' },
    ]
  }

  shared_examples_for "a left join that keeps its unmatched tuples" do
    context 'on an in-memory database' do
      let(:db) { LeftJoinMemoryDb.new }

      it 'answers the unmatched tuple too' do
        expect(subject.to_a.to_set).to eql(expected.to_set)
      end
    end

    context 'on sqlite' do
      let(:db) { LeftJoinSqliteDb.new.install }

      it 'answers the unmatched tuple too' do
        expect(subject.to_a.to_set).to eql(expected.to_set)
      end
    end
  end

  describe 'with the restriction on the right operand' do
    subject {
      current = db.members
        .restrict(state: 'active')
        .allbut([:state])
        .rename(user: :grantor)
      db.grants.left_join(current, [:grantor], { nickname: '(none)' })
    }

    it_behaves_like "a left join that keeps its unmatched tuples"
  end

  # The same join, the restriction written as a semijoin against a relation of
  # one tuple: a different way into the same compilation.
  describe 'with the right operand restricted by a matching' do
    subject {
      current = db.members
        .matching(Bmg::Relation.new([{ state: 'active' }]), [:state])
        .allbut([:state])
        .rename(user: :grantor)
      db.grants.left_join(current, [:grantor], { nickname: '(none)' })
    }

    it_behaves_like "a left join that keeps its unmatched tuples"
  end

end
