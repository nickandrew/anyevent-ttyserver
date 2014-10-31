#!/usr/bin/perl
#
#  TtyServer example script

use strict;
use warnings;

use TtyServer;

my $count = 0;

every 5 => sub {
	print "Hello, world! $count\n";

	if (++$count >= 5) {
		app->stop(6);
	}
};

line sub {
	my ($self, $line) = @_;

	if (!defined $line) {
		app->stop(0);
		return;
	}

	print "Received: $line";
	chomp($line);
	if ($line eq 'quit') {
		app->stop(0);
		return;
	}
};

my $rc = app->start;
print "Exiting code $rc\n";
exit($rc);
