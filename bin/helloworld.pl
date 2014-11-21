#!/usr/bin/perl
#
#  Print "Hello world" every 5 seconds
#  STDIN:  plain text; EOF or 'quit' to terminate script
#  STDOUT: plain text echoed from STDIN
#  Script will terminate (code 6) after 25 seconds.

use AnyEvent::TtyServer;

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
