#!/usr/bin/perl -w
##############################################################################
#     Name: server.pl
#
#  Summary: Demo server application.
#           Test in another xterm:
#           $ telnet localhost 2001
#
#  Adapted: Tue 28 Aug 2001 17:11:33 (Bob Heckel--http://1024kb.net)
##############################################################################

use IO::Socket;

# maximum number of connection requests before they get refused
$maxconn = SOMAXCONN;

#                                         arbitrary
$server = IO::Socket::INET->new(LocalPort => 2001,
                                     Type => SOCK_STREAM,
                                    Reuse => 1,
                                   Listen => $maxconn,
                               ) or die "Can't be a tcp server on " .
                                        "2001: $!\n";

# binmode does nothing under UNIX, this is for Win32 clients.
binmode(STDOUT);

$client = $server->accept();
print "Client has connected (max connections: $maxconn)\n";
$client->autoflush(1);   # may not need this
print "Connection is from ", $client->peerhost, ":", $client->peerport, "\n";
while ( <$client> ) { 
  print;
  print $client "Server received your input.\n";
}

close($client);
close($server);
