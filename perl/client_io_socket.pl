#!/usr/bin/perl -w
##############################################################################
#     Name: client_io_socket.pl
#
#  Summary: Simple client.  See server_io_socket.pl
#
# Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place lesson 13
##############################################################################
use strict;
use IO::Socket::INET;

my $client = new IO::Socket::INET (
  PeerAddr => 'localhost',
  PeerPort => 1200,
  Proto => 'tcp',
);

die "Socket could not be created. $!\n" unless $client;

$client->autoflush(1);

my $ack = <$client>;

print "Server says: $ack";
while ( <STDIN> ) {
  s/[\r\n]+$//;
  print "Sending message $_ to server\n";
  print $client "$_\n";
  # Clients and servers MUST have a protocol that tells them when it's their
  # turn to speak.
  #
  # We must read this message, or everything will go horribly wrong.  If we
  # don't know the exact format of the protocol we are creating, then we will
  # end up trying to print to the socket when the server is trying to tell us
  # something, and we will end up in deadlock.
  #
  # Our 'protocol' is simply a) the server speaks first, and b) when we write
  # a line (terminated by a newline character), we expect a line back. So when
  # you type something into the client, it sends it to the server, and then
  # waits for an acknowledgement before trying to send anything else. At the
  # other end, the server listens for a line from the client, then prints an
  # acknowledgement, then listens again. Both ends know what the other end
  # should be doing, and deadlock is avoided.
  my $msg = <$client>;
  print "Server says: $msg";
}

close $client;
