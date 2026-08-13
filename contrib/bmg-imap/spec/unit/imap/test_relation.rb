require 'spec_helper'

module Bmg::Imap
  describe Relation do

    let(:connection) do
      instance_double(Connection).tap do |c|
        allow(c).to receive(:supports_search_criteria?).and_return(true)
      end
    end

    let(:relation) do
      rel = Relation.new(Relation::DEFAULT_TYPE, imap_options)
      rel.instance_variable_set(:@connection, connection)
      rel
    end

    describe "each" do
      it 'iterates over all mailboxes by default, fetching body' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])
          .and_yield(sample_emails[1])

        result = relation.to_a
        expect(result.size).to eq(2)
        expect(result.first[:subject]).to eq("Hello World")
      end

      it 'is a Bmg::Relation' do
        allow(connection).to receive(:each_email)
        expect(relation).to be_a(Bmg::Relation)
      end
    end

    describe "type" do
      it 'has a default type with known attrlist' do
        expect(Relation::DEFAULT_TYPE.knows_attrlist?).to be(true)
        expect(Relation::DEFAULT_TYPE.attrlist).to include(:uid, :mailbox, :subject, :from, :to, :date)
      end
    end

    describe "restrict" do
      it 'pushes mailbox down as a mailbox filter' do
        allow(connection).to receive(:each_email)
          .with(["INBOX"], nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.restrict(mailbox: "INBOX").to_a
        expect(result.size).to eq(1)
      end

      it 'pushes subject down as IMAP SEARCH criteria' do
        allow(connection).to receive(:each_email)
          .with(nil, ["SUBJECT", "Hello World"], fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.restrict(subject: "Hello World").to_a
        expect(result.size).to eq(1)
      end

      it 'pushes mailbox and subject down together' do
        allow(connection).to receive(:each_email)
          .with(["Sent"], ["FROM", "alice@example.com"], fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.restrict(mailbox: "Sent", from: "alice@example.com").to_a
        expect(result.size).to eq(1)
      end

      it 'pushes uid down as IMAP UID criteria' do
        allow(connection).to receive(:each_email)
          .with(nil, ["UID", "1"], fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.restrict(uid: 1).to_a
        expect(result.size).to eq(1)
        expect(result.first[:subject]).to eq("Hello World")
      end
    end

    describe "project" do
      it 'skips body fetch when neither body_text nor raw is projected' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: false)
          .and_yield(sample_emails[0])
          .and_yield(sample_emails[1])

        result = relation.project([:uid, :subject]).to_a
        expect(result.first.keys).to eq([:uid, :subject])
      end

      it 'keeps body fetch when body_text is projected' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.project([:subject, :body_text]).to_a
        expect(result.first.keys).to eq([:subject, :body_text])
      end

      it 'keeps body fetch when raw is projected' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.project([:subject, :raw]).to_a
        expect(result.first.keys).to eq([:subject, :raw])
      end
    end

    describe "allbut" do
      it 'skips body fetch only when both body_text and raw are excluded' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: false)
          .and_yield(sample_emails[0])

        result = relation.allbut([:body_text, :raw]).to_a
        expect(result.first).not_to have_key(:body_text)
        expect(result.first).not_to have_key(:raw)
      end

      it 'keeps body fetch when only body_text is excluded (raw still needed)' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.allbut([:body_text]).to_a
        expect(result.first).not_to have_key(:body_text)
      end

      it 'keeps body fetch when only raw is excluded (body_text still needed)' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.allbut([:raw]).to_a
        expect(result.first).not_to have_key(:raw)
      end

      it 'keeps body fetch when neither body_text nor raw is excluded' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])

        result = relation.allbut([:flags]).to_a
        expect(result.first).to have_key(:body_text)
      end
    end

    describe "algebra" do
      before do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0])
          .and_yield(sample_emails[1])
      end

      it 'supports extend' do
        result = relation.extend(short_subject: ->(t) { t[:subject][0..4] }).to_a
        expect(result.first[:short_subject]).to eq("Hello")
      end
    end

    describe "labels push-down (Gmail)" do
      let(:gmail_connection) do
        instance_double(Connection).tap do |c|
          allow(c).to receive(:supports_search_criteria?).and_return(true)
        end
      end

      let(:gmail_relation) do
        rel = Relation.new(Relation::DEFAULT_TYPE, gmail_options)
        rel.instance_variable_set(:@connection, gmail_connection)
        rel
      end

      it 'pushes single-value intersect on labels via host inference' do
        allow(gmail_connection).to receive(:each_email)
          .with(nil, ["X-GM-LABELS", "Projects"], fetch_body: true)
          .and_yield(sample_emails[0])

        pred = Predicate.intersect(:labels, ["Projects"])
        result = gmail_relation.restrict(pred).to_a
        expect(result.size).to eq(1)
      end

      it 'pushes intersect on labels via explicit provider option' do
        rel = Relation.new(Relation::DEFAULT_TYPE, imap_options.merge(provider: Provider::Gmail.new))
        rel.instance_variable_set(:@connection, connection)

        allow(connection).to receive(:each_email)
          .with(nil, ["X-GM-LABELS", "Important"], fetch_body: true)
          .and_yield(sample_emails[0])

        pred = Predicate.intersect(:labels, ["Important"])
        result = rel.restrict(pred).to_a
        expect(result.size).to eq(1)
      end

      it 'does not push labels intersect on unknown hosts without provider' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0].merge(labels: ["Projects"]))
          .and_yield(sample_emails[1].merge(labels: ["Other"]))

        pred = Predicate.intersect(:labels, ["Projects"])
        result = relation.restrict(pred).to_a
        expect(result.size).to eq(1)
      end
    end

    describe "to_s" do
      it 'shows * when no mailbox restriction' do
        rel = Relation.new(Relation::DEFAULT_TYPE, imap_options)
        expect(rel.to_s).to eq("(imap imap.example.com/*)")
      end

      it 'shows mailbox name after restrict' do
        allow(connection).to receive(:each_email)
        restricted = relation.restrict(mailbox: "INBOX")
        expect(restricted.to_s).to eq("(imap imap.example.com/INBOX)")
      end
    end

    describe "delete" do
      it 'deletes matching UIDs via IMAP' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], nil)
          .and_return({ "INBOX" => [1, 2, 3] })
        expect(connection).to receive(:delete_uids).with("INBOX", [1, 2, 3])

        relation.restrict(mailbox: "INBOX").delete
      end

      it 'deletes with pushed-down search criteria' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], ["FROM", "spam@x.com"])
          .and_return({ "INBOX" => [5] })
        expect(connection).to receive(:delete_uids).with("INBOX", [5])

        relation.restrict(mailbox: "INBOX", from: "spam@x.com").delete
      end

      it 'filters in-memory when predicate is not fully pushed' do
        allow(connection).to receive(:each_email)
          .with(nil, nil, fetch_body: true)
          .and_yield(sample_emails[0].merge(mailbox: "INBOX"))
          .and_yield(sample_emails[1].merge(mailbox: "INBOX"))
        expect(connection).to receive(:delete_uids).with("INBOX", [1])

        relation.delete(Predicate.eq(:uid, 1))
      end
    end

    describe "update" do
      it 'updates flags on matching UIDs' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], ["UID", "1"])
          .and_return({ "INBOX" => [1] })
        expect(connection).to receive(:store_flags).with("INBOX", [1], [:Seen])

        relation.restrict(mailbox: "INBOX", uid: 1).update(flags: [:Seen])
      end

      it 'updates labels on matching UIDs' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], nil)
          .and_return({ "INBOX" => [1, 2] })
        expect(connection).to receive(:store_labels).with("INBOX", [1, 2], ["Projects"])

        relation.restrict(mailbox: "INBOX").update(labels: ["Projects"])
      end

      it 'moves emails to another mailbox' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], ["UID", "1"])
          .and_return({ "INBOX" => [1] })
        expect(connection).to receive(:move_uids).with("INBOX", [1], "Archive")

        relation.restrict(mailbox: "INBOX", uid: 1).update(mailbox: "Archive")
      end

      it 'applies multiple updates at once' do
        allow(connection).to receive(:search_uids)
          .with(["INBOX"], ["UID", "1"])
          .and_return({ "INBOX" => [1] })
        expect(connection).to receive(:store_flags).with("INBOX", [1], [:Seen])
        expect(connection).to receive(:store_labels).with("INBOX", [1], ["Done"])

        relation.restrict(mailbox: "INBOX", uid: 1).update(flags: [:Seen], labels: ["Done"])
      end

      it 'raises on non-updatable attributes' do
        expect {
          relation.update(subject: "New subject")
        }.to raise_error(Bmg::Error, /Cannot update subject/)
      end
    end

  end
end
