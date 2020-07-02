#!/usr/bin/perl -w
##############################################################################
#    Name: socket_demo.pl
#
# Summary: Demo of connecting to a server as a client.
#          Start httpd prior to running this code.
#
# Adapted: Sun 01 Apr 2001 21:16:35 (Bob Heckel)
##############################################################################

use strict qw(vars);
use Socket;

unless (open_TCP(SOCKHNDL, "localhost", 80) ) {
  print "Error connecting to server\n";
  exit(-1);
}

print SOCKHNDL "GET / HTTP/1.0\n\n";

my $rc = <SOCKHNDL>;
print "The server had a response line of: $rc\n";

 
sub open_TCP {
  my ($FS, $dest, $port) = @_;
 
  my $proto = getprotobyname('tcp');
  socket($FS, PF_INET, SOCK_STREAM, $proto);
  my $sin = sockaddr_in($port,inet_aton($dest));
  connect($FS,$sin) || return undef;
  my $old_fh = select($FS); 
  $| = 1;
  select($old_fh);
  1;
}
1;
