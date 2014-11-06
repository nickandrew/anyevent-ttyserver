#!/usr/bin/perl
#
#  Shell client.
#  Type a line, see it executed by the shell.

use AnyEvent::TtyServer;
use IPC::Open2;

my ($child_out, $child_in);
my $pid = open2($child_out, $child_in, "bin/shell.pl");

my $stream_in = app->stream($child_in);

line sub {
	my ($self, $line) = @_;

	if (!defined $line) {
		# EOF
		print STDERR "EOF, stopping.\n";
		app->stop(0);
		return;
	}

	chomp($line);
	$stream_in->send({cmd => $line});
};

app->stream($child_out)->json(sub {
	my ($self, $msg) = @_;

	if (!defined $msg) {
		print STDERR "$0 json EOF from peer, stopping.\n";
		app->stop(0);
		return;
	}

	if (ref($msg) eq 'HASH') {
		printf("rc: %d\n", $msg->{rc});
		print $msg->{stdout};
	}
});

app->start;
