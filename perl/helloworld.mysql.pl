#!/usr/bin/perl -w
##############################################################################
#     Name: helloworld.mysql.pl
#
#  Summary: Demo using DBI/DBD
#
#  Created: Fri 25 Jun 2004 15:59:55 (Bob Heckel)
##############################################################################
use strict;
use DBI;
  
use constant DBASE => 'fips';
  
my $dbh = DBI->connect("DBI:mysql:database=" . DBASE . ";host=localhost",
                       "bheckel",
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
  
my $sth = $dbh->prepare('select * from country');                 
$sth->execute; 
                        
while ( my $ref = $sth->fetchrow_hashref() ) {
  print "Found a row: $ref->{'statecode'}\n";
}
