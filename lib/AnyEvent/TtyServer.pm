#!/usr/bin/perl
#
#  AnyEvent::TtyServer acts a bit like a webserver, over a bidirectional tty connection
#  (STDIN and STDOUT)

package AnyEvent::TtyServer;

use strict;
use warnings;
use utf8;
use feature ();

use AnyEvent;
use IPC::Open2;
use JSON qw();
use AnyEvent::TtyServer::Stream qw();

sub import {
	my $class = shift;
	my $caller = caller;

	my $app = $class->new();

	no strict 'refs';
	*{"${caller}::app"} = sub { return $app; };

	*{"${caller}::after"} = sub { $app->after(@_); };
	*{"${caller}::every"} = sub { $app->every(@_); };
	*{"${caller}::json"} = sub { $app->json(@_); };
	*{"${caller}::line"} = sub { $app->line(@_); };
	*{"${caller}::send"} = sub { $app->send(@_); };
	*{"${caller}::on_error"} = sub { $app->{on_error} = $_[0]; };

	strict->import;
	warnings->import;
	utf8->import;
	feature->import(':5.10');
}

sub new {
	my ($class) = @_;

	my $self = {};
	bless $self, $class;

	$self->{cv} = AnyEvent->condvar;
	$self->{json} = JSON->new->utf8->canonical;

	return $self;
}

sub every {
	my ($self, $interval, $cb) = @_;

	my ($w, $keep);

	$w = AnyEvent->timer(
		after => $interval,
		interval => $interval,
		cb => sub { $cb->($self); $keep; }
	);

	# If invoked as $x = every(...) then do not keep a reference to the timer.
	# This will enable it to be cancelled later with "undef $x".
	$keep = (defined wantarray) ? undef : $w;

	return $w;
}

sub after {
	my ($self, $delay, $cb) = @_;

	my ($w, $keep);

	$w = AnyEvent->timer(
		after => $delay,
		cb => sub { $cb->($self); $keep; }
	);

	# If invoked as $x = after(...) then do not keep a reference to the timer.
	# This will enable it to be cancelled later with "undef $x".
	$keep = (defined wantarray) ? undef : $w;

	return $w;
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

sub line {
	my ($self, $cb) = @_;
	AnyEvent::TtyServer::Stream->new($self, \*STDIN)->line($cb);
}

sub json {
	my ($self, $cb) = @_;
	AnyEvent::TtyServer::Stream->new($self, \*STDIN)->json($cb);
}

sub send {
	my ($self, $ref) = @_;

	if (!defined $ref) {
		# Can't encode that
		print STDERR "Cannot encode undefined ref\n";
		return;
	}

	my $string = $self->{json}->encode($ref);
	syswrite(\*STDOUT, $string . "\n");
}

sub stream {
	my ($self, $fh) = @_;

	my $stream = AnyEvent::TtyServer::Stream->new($self, $fh);

	return $stream;
}

=head2 I<exec($self, $command)>

Execute a command. Return an array of (pid, child_in, child_out).

child_in and child_out are AnyEvent::TtyServer::Stream objects.

To use them:

	$child_in->send($data_structure);

	$child_out->json(sub { ... });

=cut

sub exec {
	my ($self, $command) = @_;

	my ($fh_out, $fh_in);
	my $pid = open2($fh_out, $fh_in, $command);

	my $child_in = $self->stream($fh_in);
	my $child_out = $self->stream($fh_out);

	return ($pid, $child_in, $child_out);
}

1;
