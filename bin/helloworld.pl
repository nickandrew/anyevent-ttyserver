#!/usr/bin/perl
#
#  TtyServer example script

use strict;
use warnings;

use TtyServer;

my $count = 0;

every 3 => sub {
	print "Hello, world!\n";

	if (++$count >= 5) {
		app->stop(6);
	}
};

json sub {
	my ($self, $w, $msg) = @_;

	my $s = JSON::encode_json({message => $msg});
	print "JSON: $s\n";
};

line sub {
	my ($self, $w, $line) = @_;

	print "Received: $line";
	chomp($line);
	if ($line eq 'quit') {
		app->stop(0);
	}
};

my $rc = app->start;
print "Exiting code $rc\n";
exit($rc);
