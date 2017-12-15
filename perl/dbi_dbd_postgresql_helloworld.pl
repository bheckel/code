#!/usr/bin/perl -w
# a simple test script for connecting to a PostgreSQL database.
#
# Copyright 2000 DVL Software Limited
# see http://freebsddiary.org/postgresql-perl.html
#
# Adapted: Sun Mar 23 10:33:45 2003 (Bob Heckel)

use DBI;
use strict;

my $dbh;
my $sth;
my @vector;
my $field;

$dbh = DBI->connect('DBI:Pg:dbname=invest', 'bheckel', '');

if ( $dbh ) {
  print "connected\n";

  $sth = $dbh->prepare("SELECT * FROM funds LIMIT 10");
  $sth->execute;

  print "<TABLE>\n";
  while ( @vector = $sth->fetchrow ) {
    print "<TR>\n";
    foreach $field ( @vector ) {
      print "<TD VALIGN=TOP>$field</TD>\n";
    }
    print "</TR>\n";
  }
  print "</TABLE>\n";

  $sth->finish;
  $dbh->disconnect();
} else {
  print "Cannot connect to Postgres server: $DBI::errstr\n";
  print " db connection failed\n";
}
