bundle:
	bundle install
	cd contrib/bmg-redis && bundle install

package: bundle
	bundle exec rake package
	cd contrib/bmg-redis && bundle exec rake package

tests: bundle
	bundle exec rake test
	cd contrib/bmg-redis && docker-compose up -d && bundle exec rake test && docker-compose down

gem.push:
	ls pkg/bmg-*.gem | xargs gem push
	ls contrib/bmg-redis/pkg/bmg-*.gem | xargs gem push
