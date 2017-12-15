package ck_tstamp;
##############################################################################
#     Name: ck_tstamp.pm
#
#  Summary: List the current files on a specific dir on an FTP site.
#
#  Created: Thu 26 Dec 2002 10:10:49 (Bob Heckel)
# Modified: Mon 10 Feb 2003 10:37:48 (Bob Heckel) 
##############################################################################
@ISA = qw(Exporter);
@EXPORT = qw(Connect List Quit);

use strict;

use Net::FTP;

sub Connect {
  my $host = shift;

  my $ftp = Net::FTP->new($host,
                          Debug   => 0,
                          Timeout => 200)
                                      or die "Can't connect: $@ Exiting.\n";
  $ftp->login('anonymous', 'bqh0@cdc.gov') 
                                     or die "Can't login:  $@.  Exiting.\n";

  return $ftp;
}


sub List {
  my $ftp = shift;
  my $location = shift;
  my $server = shift;

  my @a = $ftp->dir($location);

  print "As of ",  scalar localtime(), 
                        " on $server in directory $location\n\n";
  for ( @a ) {
    next if /^drw/;     # skip directories
    next if /^total/;   # skip the total line
    print "$_\n";
  }

  return 0;
}


sub Quit {
  my $ftp = shift;

  $ftp->quit();

  return 0;
}


1;
