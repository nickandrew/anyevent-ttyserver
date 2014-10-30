#!/usr/bin/perl
#
#  TtyServer example script
#  STDIN:  plain text, type 'quit' to exit
#  STDOUT: json with a periodic Hello World message.

use strict;
use warnings;

use TtyServer;

my $count = 0;

every 5 => sub {
	send({rc => $count, stdout => "Hello, world! $count\n"});

	if (++$count >= 5) {
		app->stop(6);
	}
};

json sub {
	my ($self, $w, $msg) = @_;

	send($msg);
};

line sub {
	my ($self, $w, $line) = @_;

	if (!defined $line) {
		app->stop(0);
		return;
	}

	chomp($line);
	if ($line eq 'quit') {
		app->stop(0);
		return;
	}

	send({line => $line});
};

my $rc = app->start;
print STDERR "Exiting code $rc\n";
exit($rc);
