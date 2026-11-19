.PHONY: test

create4.t: create4.t.template create4.pl
	awk '/^sub generate_weeks {$/,/^}$/' < create4.pl

test: create4.t
