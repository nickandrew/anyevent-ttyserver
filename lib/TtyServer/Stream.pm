#!/usr/bin/perl
#
#  Provides 1 input/output stream with json()/line()/send() functions
#  'fh' could be: STDIN, STDOUT, a pipe or a socket.

package TtyServer::Stream;

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
	my ($self) = @_;

	return if ($self->{input});

	my $w;
	$w = AnyEvent->io(
		fh => $self->{fh},
		poll => 'r',
		cb => sub {
			my $line = $self->{fh}->getline();
			if (!defined $line) {
				# EOF
				$self->{on_eof}->() if ($self->{on_eof});
				undef $w;
				delete $self->{input};
				$self->_distribute(undef, undef);
			} else {
				$self->_distribute($w, $line);
			}
		}
	);

	$self->{input} = $w;
}

sub _distribute {
	my ($self, $w, $line) = @_;

	foreach my $lr (@{$self->{distributors}}) {
		my ($func, $cb) = @$lr;
		last if ($func->($self, $w, $line, $cb));
	}
}

sub _line {
	my ($self, $w, $line, $cb) = @_;

	$cb->($self, $w, $line);
	return 1;
}

sub _json {
	my ($self, $w, $line, $cb) = @_;

	if (!defined $line) {
		$cb->($self, $w, undef);
		return 1;
	}

	my $msg = eval { JSON::decode_json($line); };

	if ($@) {
		my $e = $@;
		$self->{on_error}->("JSON decode error - $e", $line) if ($self->{on_error});
	} else {
		$cb->($self, $w, $msg);
		return 1;
	}

	return 0;
}

sub line {
	my ($self, $cb) = @_;
	$self->_inputwait();
	push(@{$self->{distributors}}, [ \&_line, $cb ]);
}

sub json {
	my ($self, $cb) = @_;
	$self->_inputwait();
	push(@{$self->{distributors}}, [ \&_json, $cb ]);
}

sub send {
	my ($self, $ref) = @_;

	my $string = $self->{json}->encode($ref);

	$self->{fh}->syswrite($string . "\n");
}

1;
