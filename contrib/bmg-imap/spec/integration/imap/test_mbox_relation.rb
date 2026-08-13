require 'spec_helper'

module Bmg::Imap
  describe "Mbox-backed Relation" do

    let(:fixture_path) { File.expand_path('../../fixtures/sample.mbox', __dir__) }

    let(:connection) { MboxConnection.new(path: fixture_path) }

    let(:emails) do
      Relation.new(Relation::DEFAULT_TYPE, connection: connection)
    end

    describe "each" do
      it 'yields all emails as tuples' do
        expect(emails.to_a.size).to eq(3)
      end

      it 'is a Bmg::Relation' do
        expect(emails).to be_a(Bmg::Relation)
      end
    end

    describe "project" do
      it 'selects specific attributes' do
        result = emails.project([:subject, :from]).to_a
        expect(result.first.keys).to eq([:subject, :from])
        expect(result.size).to eq(3)
      end
    end

    describe "restrict" do
      it 'filters by subject in memory' do
        result = emails.restrict(subject: "Project update").to_a
        expect(result.size).to eq(1)
        expect(result.first[:from]).to eq(["Charlie Davis <charlie@example.com>"])
      end

      it 'filters by mailbox (push-down to connection)' do
        result = emails.restrict(mailbox: "sample").to_a
        expect(result.size).to eq(3)
      end

      it 'filters by mailbox with no match' do
        result = emails.restrict(mailbox: "nonexistent").to_a
        expect(result.size).to eq(0)
      end

      it 'chains restrictions' do
        result = emails
          .restrict(mailbox: "sample")
          .restrict(subject: "Meeting tomorrow")
          .to_a
        expect(result.size).to eq(1)
        expect(result.first[:from]).to eq(["Alice Smith <alice@example.com>"])
      end
    end

    describe "extend" do
      it 'adds computed attributes' do
        result = emails
          .extend(sender: ->(t) { t[:from]&.first })
          .project([:subject, :sender])
          .to_a
        expect(result.first[:sender]).to eq("Alice Smith <alice@example.com>")
      end
    end

    describe "rename" do
      it 'renames attributes' do
        result = emails.rename(subject: :title).to_a
        expect(result.first).to have_key(:title)
        expect(result.first).not_to have_key(:subject)
      end
    end

    describe "allbut" do
      it 'removes attributes' do
        result = emails.allbut([:body_text, :flags, :size]).to_a
        expect(result.first).not_to have_key(:body_text)
        expect(result.first).not_to have_key(:flags)
        expect(result.first).to have_key(:subject)
      end
    end

    describe "count" do
      it 'returns the number of emails' do
        expect(emails.count).to eq(3)
      end
    end

    describe "combined operations" do
      it 'supports a realistic query pipeline' do
        result = emails
          .restrict(mailbox: "sample")
          .extend(sender: ->(t) { t[:from]&.first })
          .project([:date, :sender, :subject])
          .to_a

        expect(result.size).to eq(3)
        expect(result.first.keys).to contain_exactly(:date, :sender, :subject)
      end
    end

  end
end
