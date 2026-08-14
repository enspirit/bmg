require 'spec_helper'

module Bmg::Imap
  describe Provider do

    describe ".detect" do
      it 'returns Gmail provider when X-GM-EXT-1 is present' do
        caps = ["IMAP4rev1", "X-GM-EXT-1", "IDLE"]
        provider = Provider.detect(caps)
        expect(provider).to be_a(Provider::Gmail)
        expect(provider.name).to eq("gmail")
      end

      it 'is case-insensitive' do
        caps = ["imap4rev1", "x-gm-ext-1"]
        provider = Provider.detect(caps)
        expect(provider).to be_a(Provider::Gmail)
      end

      it 'returns Default provider when no extensions match' do
        caps = ["IMAP4rev1", "IDLE", "NAMESPACE"]
        provider = Provider.detect(caps)
        expect(provider).to be_a(Provider::Default)
        expect(provider.name).to eq("default")
      end

      it 'returns Default provider for empty capabilities' do
        provider = Provider.detect([])
        expect(provider).to be_a(Provider::Default)
      end
    end

    describe ".infer_from_host" do
      it 'returns Gmail for imap.gmail.com' do
        expect(Provider.infer_from_host("imap.gmail.com")).to be_a(Provider::Gmail)
      end

      it 'returns Gmail for imap.googlemail.com' do
        expect(Provider.infer_from_host("imap.googlemail.com")).to be_a(Provider::Gmail)
      end

      it 'returns nil for unknown hosts' do
        expect(Provider.infer_from_host("imap.example.com")).to be_nil
      end

      it 'returns nil for nil host' do
        expect(Provider.infer_from_host(nil)).to be_nil
      end
    end

    describe Provider::Default do
      let(:provider) { Provider::Default.new }

      it 'has no extra fetch attrs' do
        expect(provider.extra_fetch_attrs).to eq([])
      end

      it 'returns default labels as empty array' do
        result = provider.parse_extra(double)
        expect(result).to eq({ labels: [] })
      end

      it 'has defaults for all official extra attributes' do
        expect(provider.defaults).to eq({ labels: [] })
      end

      it 'has no search attrs' do
        expect(provider.search_attrs).to eq({})
      end

      it 'has no intersect attrs' do
        expect(provider.intersect_attrs).to eq({})
      end

      describe '#delete_uids' do
        it 'delegates to connection.expunge_uids (standard IMAP recipe)' do
          connection = instance_double(Connection)
          expect(connection).to receive(:expunge_uids).with("INBOX", [1, 2, 3])
          provider.delete_uids(connection, "INBOX", [1, 2, 3])
        end
      end
    end

    describe Provider::Gmail do
      let(:provider) { Provider::Gmail.new }

      it 'requests X-GM-LABELS in fetch' do
        expect(provider.extra_fetch_attrs).to eq(["X-GM-LABELS"])
      end

      it 'parses X-GM-LABELS into :labels' do
        item = double(attr: { "X-GM-LABELS" => ["\\Inbox", "Projects", "Important"] })
        result = provider.parse_extra(item)
        expect(result).to eq({ labels: ["\\Inbox", "Projects", "Important"] })
      end

      it 'returns empty labels when X-GM-LABELS is nil' do
        item = double(attr: { "X-GM-LABELS" => nil })
        result = provider.parse_extra(item)
        expect(result).to eq({ labels: [] })
      end

      it 'returns empty labels when X-GM-LABELS is absent' do
        item = double(attr: {})
        result = provider.parse_extra(item)
        expect(result).to eq({ labels: [] })
      end

      it 'declares labels as an intersect attr' do
        expect(provider.intersect_attrs).to eq({ labels: "X-GM-LABELS" })
      end

      it 'has no eq search attrs' do
        expect(provider.search_attrs).to eq({})
      end

      describe '#delete_uids' do
        let(:connection) { instance_double(Connection) }

        it 'moves to Trash discovered via SPECIAL-USE' do
          allow(connection).to receive(:find_special_use_mailbox).with(:Trash)
            .and_return("[Gmail]/Bin")
          expect(connection).to receive(:move_uids).with("INBOX", [1, 2], "[Gmail]/Bin")
          provider.delete_uids(connection, "INBOX", [1, 2])
        end

        it 'falls back to a well-known Gmail trash name when SPECIAL-USE is unavailable' do
          allow(connection).to receive(:find_special_use_mailbox).with(:Trash).and_return(nil)
          allow(connection).to receive(:list_mailbox_names)
            .and_return(["INBOX", "[Gmail]/Trash", "[Gmail]/Sent Mail"])
          expect(connection).to receive(:move_uids).with("INBOX", [1], "[Gmail]/Trash")
          provider.delete_uids(connection, "INBOX", [1])
        end

        it 'expunges in place when the source mailbox is already the trash' do
          allow(connection).to receive(:find_special_use_mailbox).with(:Trash)
            .and_return("[Gmail]/Bin")
          expect(connection).to receive(:expunge_uids).with("[Gmail]/Bin", [1, 2])
          provider.delete_uids(connection, "[Gmail]/Bin", [1, 2])
        end

        it 'expunges in place when no trash mailbox can be resolved' do
          allow(connection).to receive(:find_special_use_mailbox).with(:Trash).and_return(nil)
          allow(connection).to receive(:list_mailbox_names).and_return(["INBOX", "Archive"])
          expect(connection).to receive(:expunge_uids).with("INBOX", [3])
          provider.delete_uids(connection, "INBOX", [3])
        end

        it 'caches the resolved trash mailbox across calls' do
          expect(connection).to receive(:find_special_use_mailbox).with(:Trash)
            .once.and_return("[Gmail]/Bin")
          allow(connection).to receive(:move_uids)
          provider.delete_uids(connection, "INBOX", [1])
          provider.delete_uids(connection, "INBOX", [2])
        end
      end
    end

  end
end
