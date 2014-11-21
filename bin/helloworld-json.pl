#!/usr/bin/perl
#
#  AnyEvent::TtyServer example script
#  STDIN:  json; EOF to terminate script
#  STDOUT: json with a periodic Hello World message.
#  Script will terminate (code 6) after 25 seconds.

use AnyEvent::TtyServer;

my $count = 0;

every 5 => sub {
	send({rc => $count, stdout => "Hello, world! $count\n"});

	if (++$count >= 5) {
		app->stop(6);
	}
};

json sub {
	my ($self, $msg) = @_;

	if (!defined $msg) {
		app->stop(0);
		return;
	}

	send({received => $msg});
};

my $rc = app->start;
print STDERR "Exiting code $rc\n";
exit($rc);
