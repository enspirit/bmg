package:
	bundle exec rake package
	cd contrib/bmg-redis && bundle exec rake package

bundle:
	bundle install
	cd contrib/bmg-redis && bundle install

tests: bundle
	bundle exec rake test
	cd contrib/bmg-redis && docker-compose up -d && bundle exec rake test && docker-compose down

gem.push:
	ls pkg/bmg-*.gem contrib/bmg-redis/pkg/bmg-*.gem | xargs gem push
