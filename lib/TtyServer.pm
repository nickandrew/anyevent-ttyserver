#!/usr/bin/perl
#
#  TtyServer acts a bit like a webserver, over a bidirectional tty connection
#  (STDIN and STDOUT)

package TtyServer;

use strict;
use warnings;
use utf8;
use feature ();

use AnyEvent;
use JSON qw();
use TtyServer::Stream qw();

sub import {
	my $class = shift;
	my $caller = caller;

	my $app = $class->new();

	no strict 'refs';
	*{"${caller}::app"} = sub { return $app; };
	*{"${caller}::every"} = sub { $app->every(@_); };
	*{"${caller}::line"} = sub { $app->line(@_); };
	*{"${caller}::json"} = sub { $app->json(@_); };
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

	my $w;
	$w = AnyEvent->timer(
		after => $interval,
		interval => $interval,
		cb => sub { $cb->($self, $w); }
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

sub line {
	my ($self, $cb) = @_;
	TtyServer::Stream->new($self, \*STDIN)->line($cb);
}

sub json {
	my ($self, $cb) = @_;
	TtyServer::Stream->new($self, \*STDIN)->json($cb);
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

	my $stream = TtyServer::Stream->new($self, $fh);

	return $stream;
}

1;
