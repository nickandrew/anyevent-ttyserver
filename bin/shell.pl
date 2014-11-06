#!/usr/bin/perl
#
#  Server to run shell commands

use AnyEvent::TtyServer;

json sub {
	my ($self, $msg) = @_;

	if (!defined $msg) {
		print STDERR "$0 json EOF from peer, stopping.\n";
		app->stop(0);
		return;
	}

	my $r = ref($msg);
	if (!$r) {
		app->stop(0);
		return;
	}
	elsif ($r eq 'HASH') {
		if ($msg->{cmd}) {
			my $cmd = $msg->{cmd};
			print STDERR "cmd is <$cmd>\n";
			open(OF, "$cmd|");
			my @response = <OF>;
			close(OF);
			my $rc = $?;
			my $output = join('', @response);
			send { rc => $rc, stdout => $output};
		}
		elsif (defined $msg->{quit}) {
			app->stop(0);
			return;
		}
	}
};

app->start;
