#!/usr/bin/perl
#
#  TtyServer acts a bit like a webserver, over a bidirectional tty connection
#  (STDIN and STDOUT)

package TtyServer;

sub import {
	my $class = shift;
	my $caller = caller;

	my $app = $class->new();

	*{"${caller}::app"} = sub { return $app; };
	*{"${caller}::every"} = sub { $app->every(@_); };
}

sub new {
	my ($class) = @_;

	my $self = {};
	bless $self, $class;

	return $self;
}

sub every {
	my ($self, $interval, $sub) = @_;
}

sub start {
	my $self = shift;
}

1;
