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
