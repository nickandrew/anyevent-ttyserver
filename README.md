# AnyEvent::TtyServer

Simple non-blocking framework for JSON messages over pipes or ssh

## What it's for

This framework allows you to write a simple 'server' in perl, that
can communicate with a 'client' using non-blocking JSON formatted
messages. The client and server may be connected via pipes (e.g.
as a child process) or (more usefully) across an ssh connection.

Example of a simple server script:

```perl
#!/usr/bin/perl
#
#  AnyEvent::TtyServer example script
#  STDIN:  plain text, type 'quit' to exit
#  STDOUT: json with a periodic Hello World message.

use AnyEvent::TtyServer;

my $count = 0;

every 5 => sub {
	send({rc => $count, stdout => "Hello, world! $count\n"});

	if (++$count >= 5) {
		app->stop(6);
	}
};

json sub {
	my ($self, $msg) = @_;

	if (!defined $msg) {
		app->stop(0);
		return;
	}

	send({received => $msg});
};

my $rc = app->start;
exit($rc);
```

## Explanation

This framework uses the AnyEvent module for non-blocking I/O. All the code runs from the
AnyEvent event loop, so it will be event-driven.

_every_ will run a subroutine periodically. "every 5" means run every 5 seconds.

_json_ sets a subroutine which will be called whenever a JSON formatted message is received
on STDIN. The $msg argument contains the decoded data structure.

The alternative to _json_ for unformatted data is _line_ which is called with the
received line, unprocessed.

There can be only one _json_ or _line_ subroutine.

Call _app->start_ after defining event-driven subroutines, to start the AnyEvent event
loop. To stop the application, call app->stop() with an exit code.

## Writing a client

A client is very similar to a server (indeed, the protocol does not distinguish between
clients and servers). However it is likely that a client's connection to a server will
be on some file descriptor other than STDIN/STDOUT.

To process messages from some other file handle, use the app->stream() function.
For example,

```perl
my $stream = app->stream($fh);

$stream->send( { data => "abcd" } );

$stream->json(sub { print "Received a message.\n"; });
```

## Communicating across an ssh login

To make an ssh connection to another host and run a server process on
that host, do:

```perl
my ($pid, $child_in, $child_out) = app->exec("ssh hostname server.pl");

$child_in->send( { data => "abcd" } );

$child_out->json(sub { print "Received a message.\n"; });
```

## Credits

Huge props to Mojolicious, upon which I modeled this design. Mojo has a really nice API
and underlying design.
