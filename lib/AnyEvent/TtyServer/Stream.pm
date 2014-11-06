#!/usr/bin/perl
#
#  Provides 1 input/output stream with json()/line()/send() functions
#  'fh' could be: STDIN, STDOUT, a pipe or a socket.

package AnyEvent::TtyServer::Stream;

use strict;
use warnings;

use JSON qw();

sub new {
	my ($class, $app, $fh) = @_;

	my $self = {
		app => $app,
		fh  => $fh,
	};
	bless $self, $class;

	$self->{json} = JSON->new->utf8->canonical;

	return $self;
}

sub _inputwait {
	my ($self, $func, $cb) = @_;

	my $w = AnyEvent->io(
		fh => $self->{fh},
		poll => 'r',
		cb => sub {
			my $line = $self->{fh}->getline();
			if (!defined $line) {
				# EOF
				$self->{on_eof}->() if ($self->{on_eof});
				delete $self->{input};
				$func->($self, undef, $cb);
			} else {
				$func->($self, $line, $cb);
			}
		}
	);

	$self->{input} = $w;
}

sub _line {
	my ($self, $line, $cb) = @_;

	$cb->($self, $line);
	return;
}

sub _json {
	my ($self, $line, $cb) = @_;

	if (!defined $line) {
		$cb->($self, undef);
		return;
	}

	my $msg = eval { JSON::decode_json($line); };

	if ($@) {
		my $e = $@;
		$self->{on_error}->("JSON decode error - $e", $line) if ($self->{on_error});
		$cb->($self, undef);
	} else {
		$cb->($self, $msg);
	}

	return;
}

sub line {
	my ($self, $cb) = @_;
	$self->_inputwait(\&_line, $cb);
}

sub json {
	my ($self, $cb) = @_;
	$self->_inputwait(\&_json, $cb);
}

sub send {
	my ($self, $ref) = @_;

	my $string = $self->{json}->encode($ref);

	$self->{fh}->syswrite($string . "\n");
}

1;
