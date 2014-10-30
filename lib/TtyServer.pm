#!/usr/bin/perl
#
#  TtyServer acts a bit like a webserver, over a bidirectional tty connection
#  (STDIN and STDOUT)

package TtyServer;

use strict;
use warnings;

use AnyEvent;

sub import {
	my $class = shift;
	my $caller = caller;

	my $app = $class->new();

	no strict 'refs';
	*{"${caller}::app"} = sub { return $app; };
	*{"${caller}::every"} = sub { $app->every(@_); };
}

sub new {
	my ($class) = @_;

	my $self = {};
	bless $self, $class;

	$self->{cv} = AnyEvent->condvar;

	return $self;
}

sub every {
	my ($self, $interval, $sub) = @_;

	my $w;
	$w = AnyEvent->timer(
		after => $interval,
		interval => $interval,
		cb => sub { $sub->($self, $w); }
	);
}

sub start {
	my $self = shift;

	# Start IO loop
	my $rc = $self->{cv}->recv;

	return $rc;
}

sub stop {
	my($self, $rc) = @_;

	$self->{cv}->send($rc);
}

1;
