#!/usr/bin/perl
#
#  Server to run shell commands

use strict;
use warnings;

use TtyServer;

json sub {
	my ($self, $w, $msg) = @_;

	my $r = ref($msg);
	if (!$r) {
		if ($msg eq "quit\n") {
			app->stop(0);
		}
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
		}
	}
};

app->start;
