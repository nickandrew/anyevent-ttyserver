#!/usr/bin/perl
#
#  TtyServer example script

use TtyServer qw(every);

every 3 => sub {
	print "Hello, world!\n";
};

app->start;
