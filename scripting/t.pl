#!/usr/bin/perl

use IO::Socket::INET;

$| = 1;
my $socket = new IO::Socket::INET(
  #PeerHost => 'plcm05.foo.com',
  #PeerPort => '6500',
  #PeerHost => 'yahoo.com',
  #PeerPort => '443',
  #PeerHost => '129.158.230.148',
  PeerHost => 'rshdev.com',
  PeerPort => '25',
  Proto => 'tcp',
);
die "cannot connect to the server: $!\n" unless $socket;
print "connected to the server\n";

$data = <$socket>;
print "$data";

print $socket "EHLO rshdev.com\n";
#while ( $data = <$socket> ) {
  print "$data";
#}

print $socket "MAIL FROM:<heckel@sdf.org>\n";
#while ( $data = <$socket> ) {
#  print "$data";
#}

print $socket "RCPT TO<pc@rshdev.com>\n";
#while ( $data = <$socket> ) {
#  print "$data";
#}

print $socket "ETRN rshdev.com\n";
print $socket "DATA\n";
print $socket "just a test\n";
print $socket ".\n";
print $socket "QUIT\n";

print "$data";

#
##print $socket "DATA\n";
#$data = <$socket>;
#print "Received from Server : $data\n";
#
##print $socket "just a test\n";
#$data = <$socket>;
#print "Received from Server : $data\n";
#
##print $socket ".\n";
#$data = <$socket>;
#print "Received from Server : $data\n";
#
##print $socket "QUIT\n";
#$data = <$socket>;
#print "Received from Server : $data\n";

#sleep (5);
$socket->close();
