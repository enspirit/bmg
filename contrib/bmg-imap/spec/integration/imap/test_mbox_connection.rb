require 'spec_helper'

module Bmg::Imap
  describe MboxConnection do

    let(:fixture_path) { File.expand_path('../../fixtures/sample.mbox', __dir__) }

    let(:connection) { MboxConnection.new(path: fixture_path) }

    describe "list_mailbox_names" do
      it 'returns the filename without extension for a single file' do
        expect(connection.list_mailbox_names).to eq(["sample"])
      end
    end

    describe "each_email" do
      let(:emails) { connection.each_email.to_a }

      it 'returns all emails from the mbox file' do
        expect(emails.size).to eq(3)
      end

      it 'parses uid as sequential integers' do
        expect(emails.map { |e| e[:uid] }).to eq([1, 2, 3])
      end

      it 'sets mailbox to the file basename' do
        expect(emails.map { |e| e[:mailbox] }.uniq).to eq(["sample"])
      end

      it 'parses subject' do
        expect(emails[0][:subject]).to eq("Meeting tomorrow")
        expect(emails[1][:subject]).to eq("Re: Meeting tomorrow")
        expect(emails[2][:subject]).to eq("Project update")
      end

      it 'parses from as formatted address list' do
        expect(emails[0][:from]).to eq(["Alice Smith <alice@example.com>"])
        expect(emails[1][:from]).to eq(["Bob Jones <bob@example.com>"])
      end

      it 'parses to as formatted address list' do
        expect(emails[0][:to]).to eq(["Bob Jones <bob@example.com>"])
        expect(emails[1][:to]).to eq(["Alice Smith <alice@example.com>"])
      end

      it 'parses cc when present' do
        expect(emails[0][:cc]).to eq([])
        expect(emails[2][:cc]).to eq(["Bob Jones <bob@example.com>"])
      end

      it 'parses date as DateTime' do
        expect(emails[0][:date]).to be_a(DateTime)
        expect(emails[0][:date].year).to eq(2025)
        expect(emails[0][:date].month).to eq(1)
        expect(emails[0][:date].day).to eq(13)
      end

      it 'parses message_id' do
        expect(emails[0][:message_id]).to eq("<msg001@example.com>")
      end

      it 'parses in_reply_to' do
        expect(emails[0][:in_reply_to]).to be_nil
        expect(emails[1][:in_reply_to]).to eq("msg001@example.com")
      end

      it 'parses bcc (empty when absent)' do
        expect(emails[0][:bcc]).to eq([])
      end


      it 'parses flags from Status header' do
        expect(emails[0][:flags]).to include(:Seen) # Status: RO
        expect(emails[1][:flags]).to include(:Seen) # Status: R
        expect(emails[2][:flags]).to eq([])          # No Status header
      end

      it 'computes size from raw message bytes' do
        expect(emails[0][:size]).to be_a(Integer)
        expect(emails[0][:size]).to be > 0
      end

      it 'parses body text' do
        expect(emails[0][:body_text]).to include("Can we meet tomorrow")
        expect(emails[1][:body_text]).to include("10am works for me")
      end
    end

    describe "each_email with mailbox filter" do
      it 'yields emails only for matching mailbox' do
        emails = connection.each_email(["sample"]).to_a
        expect(emails.size).to eq(3)
      end

      it 'yields nothing for non-existent mailbox' do
        emails = connection.each_email(["nonexistent"]).to_a
        expect(emails.size).to eq(0)
      end
    end

    describe "directory mode" do
      let(:dir_path) { File.expand_path('../../fixtures', __dir__) }
      let(:dir_connection) { MboxConnection.new(path: dir_path) }

      it 'lists all .mbox files as mailbox names' do
        names = dir_connection.list_mailbox_names
        expect(names).to include("sample")
      end

      it 'reads emails from selected mailbox' do
        emails = dir_connection.each_email(["sample"]).to_a
        expect(emails.size).to eq(3)
        expect(emails.first[:mailbox]).to eq("sample")
      end
    end

  end
end
