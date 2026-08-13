require 'spec_helper'

module Bmg::Imap
  describe PredicateTranslator do

    let(:translator) { PredicateTranslator.new }

    def translate(predicate)
      translator.call(Predicate.coerce(predicate))
    end

    # Helper: build predicates using Predicate factory
    def p_eq(attr, value)
      Predicate.eq(attr, value)
    end

    def p_gt(attr, value)
      Predicate.gt(attr, value)
    end

    def p_gte(attr, value)
      Predicate.gte(attr, value)
    end

    def p_lt(attr, value)
      Predicate.lt(attr, value)
    end

    def p_lte(attr, value)
      Predicate.lte(attr, value)
    end

    describe "mailbox extraction" do
      it 'extracts a simple mailbox equality' do
        mailboxes, criteria, remaining = translate(mailbox: "INBOX")
        expect(mailboxes).to eq(["INBOX"])
        expect(criteria).to be_nil
        expect(remaining).to be_nil
      end

      it 'returns nil mailboxes when no mailbox restriction' do
        mailboxes, _, _ = translate(subject: "Hello")
        expect(mailboxes).to be_nil
      end

      it 'separates mailbox from other criteria' do
        mailboxes, criteria, remaining = translate(mailbox: "Sent", from: "alice@example.com")
        expect(mailboxes).to eq(["Sent"])
        expect(criteria).to eq(["FROM", "alice@example.com"])
        expect(remaining).to be_nil
      end
    end

    describe "equality push-down" do
      it 'translates subject equality' do
        _, criteria, remaining = translate(subject: "Hello")
        expect(criteria).to eq(["SUBJECT", "Hello"])
        expect(remaining).to be_nil
      end

      it 'translates from equality' do
        _, criteria, _ = translate(from: "alice@example.com")
        expect(criteria).to eq(["FROM", "alice@example.com"])
      end

      it 'translates to equality' do
        _, criteria, _ = translate(to: "bob@example.com")
        expect(criteria).to eq(["TO", "bob@example.com"])
      end

      it 'translates cc equality' do
        _, criteria, _ = translate(cc: "carol@example.com")
        expect(criteria).to eq(["CC", "carol@example.com"])
      end

      it 'translates uid equality' do
        _, criteria, _ = translate(uid: 42)
        expect(criteria).to eq(["UID", "42"])
      end

      it 'translates uid equality with string' do
        _, criteria, _ = translate(uid: "123")
        expect(criteria).to eq(["UID", "123"])
      end
    end

    describe "combined equality push-downs" do
      it 'combines multiple pushable attributes' do
        _, criteria, remaining = translate(from: "alice@example.com", subject: "Hello")
        expect(criteria).to include("FROM", "alice@example.com")
        expect(criteria).to include("SUBJECT", "Hello")
        expect(criteria.size).to eq(4)
        expect(remaining).to be_nil
      end

      it 'combines mailbox with multiple search criteria' do
        mailboxes, criteria, remaining = translate(mailbox: "INBOX", from: "alice@example.com", subject: "Test")
        expect(mailboxes).to eq(["INBOX"])
        expect(criteria).to include("FROM", "alice@example.com")
        expect(criteria).to include("SUBJECT", "Test")
        expect(remaining).to be_nil
      end
    end

    describe "date comparison push-down" do
      let(:date) { Date.new(2025, 3, 15) }

      it 'translates date > as SINCE' do
        _, criteria, _ = translate(p_gt(:date, date))
        expect(criteria).to eq(["SINCE", "15-Mar-2025"])
      end

      it 'translates date >= as SINCE' do
        _, criteria, _ = translate(p_gte(:date, date))
        expect(criteria).to eq(["SINCE", "15-Mar-2025"])
      end

      it 'translates date < as BEFORE' do
        _, criteria, _ = translate(p_lt(:date, date))
        expect(criteria).to eq(["BEFORE", "15-Mar-2025"])
      end

      it 'translates date <= as BEFORE' do
        _, criteria, _ = translate(p_lte(:date, date))
        expect(criteria).to eq(["BEFORE", "15-Mar-2025"])
      end

      it 'combines date range with other criteria' do
        pred = p_gte(:date, date) & p_eq(:from, "alice@example.com")
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to include("SINCE", "15-Mar-2025")
        expect(criteria).to include("FROM", "alice@example.com")
        expect(remaining).to be_nil
      end
    end

    describe "non-pushable predicates become remaining" do
      it 'leaves unknown attributes in remaining' do
        pred = Predicate.coerce(flags: [:Seen])
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to be_nil
        expect(remaining).to eq(pred)
      end

      it 'leaves size equality in remaining' do
        _, criteria, remaining = translate(size: 1234)
        expect(criteria).to be_nil
        expect(remaining).to eq(p_eq(:size, 1234))
      end

      it 'splits pushable and non-pushable attributes' do
        pred = p_eq(:from, "alice@example.com") & p_eq(:size, 1234)
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to eq(["FROM", "alice@example.com"])
        expect(remaining).to eq(p_eq(:size, 1234))
      end
    end

    describe "unsupported predicate forms" do
      it 'does not push OR predicates' do
        pred = p_eq(:from, "alice") | p_eq(:from, "bob")
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to be_nil
        expect(remaining).to eq(pred)
      end

      it 'does not push NOT predicates' do
        pred = !p_eq(:from, "alice")
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to be_nil
        expect(remaining).to eq(pred)
      end

      it 'does not push date equality (only comparisons)' do
        date = Date.new(2025, 1, 1)
        _, criteria, remaining = translate(date: date)
        expect(criteria).to be_nil
        expect(remaining).to eq(p_eq(:date, date))
      end
    end

    describe "tautology" do
      it 'returns all nils for a tautology' do
        pred = Predicate.tautology
        mailboxes, criteria, remaining = translator.call(pred)
        expect(mailboxes).to be_nil
        expect(criteria).to be_nil
        expect(remaining).to be_nil
      end
    end

    describe "complex combinations" do
      it 'handles mailbox + pushable + non-pushable' do
        pred = p_eq(:mailbox, "INBOX") & p_eq(:from, "alice@example.com") & p_eq(:size, 500)
        mailboxes, criteria, remaining = translator.call(pred)
        expect(mailboxes).to eq(["INBOX"])
        expect(criteria).to eq(["FROM", "alice@example.com"])
        expect(remaining).to eq(p_eq(:size, 500))
      end

      it 'handles date range (between two dates)' do
        d1 = Date.new(2025, 1, 1)
        d2 = Date.new(2025, 6, 30)
        pred = p_gte(:date, d1) & p_lt(:date, d2)
        _, criteria, remaining = translator.call(pred)
        expect(criteria).to include("SINCE", "1-Jan-2025")
        expect(criteria).to include("BEFORE", "30-Jun-2025")
        expect(remaining).to be_nil
      end
    end

  end
end
