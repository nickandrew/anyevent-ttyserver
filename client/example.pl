#!/usr/bin/perl
#
#  Example client script: Connect to helloworld-json.pl

use AnyEvent::TtyServer;

my ($pid, $child_in, $child_out) = app->exec("bin/helloworld-json.pl");

$child_out->json(sub {
	my ($self, $msg) = @_;

	if (!defined $msg) {
		app->stop(0);
		return;
	}

	if (ref($msg) eq 'HASH') {
		printf("rc: %d\n", $msg->{rc});
		print $msg->{stdout};
	}
});

app->start;
