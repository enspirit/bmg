require 'spec_helper'
module Bmg
  module Reader
    describe TextFile do

      let(:file) {
        Path.dir/("example.txt")
      }

      let(:csv) {
        csv = TextFile.new(Type::ANY, file, options)
      }

      context 'without options' do
        let(:options){ {} }

        it 'works' do        
          expect(csv.to_a).to eql([
            { line: 1, text: %Q{83.149.9.216 - - [17/May/2015:10:05:03 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-search.png HTTP/1.1" 200 203023 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"} },
            { line: 2, text: %Q{50.16.19.13 - - [17/May/2015:10:05:10 +0000] "GET /blog/tags/puppet?flav=rss20 HTTP/1.1" 200 14872 "http://www.semicomplete.com/blog/tags/puppet?flav=rss20" "Tiny Tiny RSS/1.11 (http://tt-rss.org/)"} },
            { line: 3, text: %Q{66.249.73.185 - - [17/May/2015:10:05:37 +0000] "GET / HTTP/1.1" 200 37932 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"} }
          ])
        end

        it 'has the expected type' do
          expect(csv.type.knows_attrlist?).to eql(true)
          expect(csv.type.attrlist).to eql([:line, :text])
        end
      end

      context 'with strip: false' do
        let(:options){ {strip: false} }

        it 'works' do
          expect(csv.to_a).to eql([
            { line: 1, text: %Q{83.149.9.216 - - [17/May/2015:10:05:03 +0000] "GET /presentations/logstash-monitorama-2013/images/kibana-search.png HTTP/1.1" 200 203023 "http://semicomplete.com/presentations/logstash-monitorama-2013/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"\n} },
            { line: 2, text: %Q{50.16.19.13 - - [17/May/2015:10:05:10 +0000] "GET /blog/tags/puppet?flav=rss20 HTTP/1.1" 200 14872 "http://www.semicomplete.com/blog/tags/puppet?flav=rss20" "Tiny Tiny RSS/1.11 (http://tt-rss.org/)"\n} },
            { line: 3, text: %Q{66.249.73.185 - - [17/May/2015:10:05:37 +0000] "GET / HTTP/1.1" 200 37932 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"\n} }
          ])
        end
      end

      context 'with parse: /.../' do
        let(:options){ { parse: /\A(?<ip>(\d+\.){3}\d+)/ } }

        it 'works' do
          expect(csv.to_a).to eql([
            { line: 1, ip: "83.149.9.216" },
            { line: 2, ip: "50.16.19.13"  },
            { line: 3, ip: "66.249.73.185" }
          ])
        end

        it 'has the expected type' do
          expect(csv.type.knows_attrlist?).to eql(true)
          expect(csv.type.attrlist).to eql([:line, :ip])
        end
      end

      context 'with /.../' do
        let(:options){ /\A(?<ip>(\d+\.){3}\d+)/ }

        it 'works' do
          expect(csv.to_a).to eql([
            { line: 1, ip: "83.149.9.216" },
            { line: 2, ip: "50.16.19.13"  },
            { line: 3, ip: "66.249.73.185" }
          ])
        end

        it 'has the expected type' do
          expect(csv.type.knows_attrlist?).to eql(true)
          expect(csv.type.attrlist).to eql([:line, :ip])
        end
      end

      context 'with /.../ that does not match sometimes' do
        let(:options){ /\A(?<ip>83\.(\d+\.){2}\d+)/ }

        it 'works' do
          expect(csv.to_a).to eql([
            { line: 1, ip: "83.149.9.216" }
          ])
        end
      end

    end
  end
end
