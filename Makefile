package:
	bundle exec rake package

tests:
	bundle exec rake test

gem.push:
	ls pkg/bmg-*.gem | xargs gem push
