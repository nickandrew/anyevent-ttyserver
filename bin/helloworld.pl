#!/usr/bin/perl
#
#  TtyServer example script

use TtyServer qw(every);

my $count = 0;

every 3 => sub {
	print "Hello, world!\n";

	if (++$count >= 5) {
		app->stop(6);
	}
};

my $rc = app->start;
print "Exiting code $rc\n";
exit($rc);
