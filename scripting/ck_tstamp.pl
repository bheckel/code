#!/usr/bin/perl -w
##############################################################################
#     Name: ck_tstamp.pl
#
#  Summary: List the current files on a specific dir on an FTP site.
#
#  Created: Thu 26 Dec 2002 10:10:49 (Bob Heckel)
##############################################################################

print "Content-type: text/html\n\n";

use strict;

use Net::FTP;

my $conn = undef;
my $server = 'webstats.cdc.gov';
my $serverdir = 'www2/2002';

$conn = Connect($server);
print "As of ",  scalar localtime(), 
                             " on $server in directory $serverdir:<BR><BR>";
List($conn, $serverdir);
Quit($conn);


sub Connect {
  my $host = shift;

  my $ftp = Net::FTP->new($host,
                          Debug   => 1,
                          Timeout => 200)
                                      or die "Can't connect: $@ Exiting.\n";
  $ftp->login('anonymous', 'bqh0@cdc.gov') 
                                     or die "Can't login:  $@.  Exiting.\n";
  $ftp->type('I');

  return $ftp;
}


sub List {
  my $ftp = shift;
  my $location = shift;

  my @a = $ftp->dir($location);

  for ( @a ) {
    print "<FONT FACE='courier new'>$_</FONT><BR>";
  }

  return 0;
}


sub Quit {
  my $ftp = shift;

  $ftp->quit();

  return 0;
}
