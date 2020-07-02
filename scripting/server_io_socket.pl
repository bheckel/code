#!/usr/bin/perl -w
##############################################################################
#     Name: server_io_socket.pl
#
#  Summary: Simple server.  Test via  
#           $ telnet localhost 1200 
#           or run client_io_socket.pl after starting this server.
#
#           Does nothing but accept the connection, parrot and quit when
#           asked.
#
# Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place lesson 13
##############################################################################
use strict;
use IO::Socket::INET;

my $server = new IO::Socket::INET (
  LocalHost     => 'localhost',
  LocalPort     => 1200,
  Proto         => 'tcp',
  Listen        => 1,
  Reuse         => 1,
);

die "Can't create socket: $!\n" unless $server;

$server->autoflush(1);
while ( my $sock_handle = $server->accept() ) {
  # TODO fork so others can join
  print "Accepting a connection from ", $sock_handle->peerhost(), ".\n";
  print $sock_handle "Welcome.\n";
  LINE: while ( $_ = <$sock_handle> ) {
          s/[\r\n]+$//;
          print "\tClient request: $_\n";
          for ( $_ ) {
            /^QUIT$/i && do
              {
                  print $sock_handle "Bye!\n";
                  close $sock_handle;
                  last LINE;
              };
            /^HELP$/i && do
              {
                  print $sock_handle "You'll be lucky.\n";
                  next LINE;
              };
            print $sock_handle "Acknowledged $_.\n";
          }
  }
}
close $server;
