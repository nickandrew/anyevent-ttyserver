#!/usr/bin/perl
#
#  AnyEvent::TtyServer example script
#  STDIN:  plain text, type 'quit' to exit
#  STDOUT: json with a periodic Hello World message.

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
