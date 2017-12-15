#!/usr/bin/perl -w
##############################################################################
#    Name: dbi_dbd_csv.pl
#
# Summary: Demo of how to use DBI's DBD::CSV and SQL queries to CREATE and
#          then query.
#
#          Assumes DBI-1_13.tar.gz SQL-Statement-0_1016.tar.gz
#          Text-CSV_XS-0_20.tar.gz DBD-CSV-0_1022.tar.gz have been
#          installed.
#
#  Created: Fri, 26 Nov 1999 14:10:09 (Bob Heckel)
# Modified: Wed 23 May 2001 16:49:25 (Bob Heckel)
##############################################################################

use DBI;

# Create new table in predefined subdirectory (subdir is the 'database').
$dbh = DBI->connect("DBI:CSV:f_dir=/home/bheckel/tmp/testing")
    or die "Cannot connect: " . $DBI::errstr;

$sth = $dbh->prepare("CREATE TABLE bobo (id INTEGER, name CHAR(10))")
    or die "Cannot prepare: " . $dbh->errstr();

$sth->execute() or die "Cannot execute: " . $sth->errstr();
$sth->finish();       
$dbh->disconnect();

# Populate table bobo with data.
$dbh = DBI->connect("DBI:CSV:f_dir=/home/bheckel/tmp/testing");

$dbh->do("INSERT INTO bobo VALUES (42, " . $dbh->quote("bobha") . ")");
$dbh->do("INSERT INTO bobo VALUES (43, " . $dbh->quote("bobhb") . ")");
$dbh->do("INSERT INTO bobo VALUES (44, " . $dbh->quote("bobhc") . ")");
$dbh->do("INSERT INTO bobo VALUES (45, " . $dbh->quote("bobhc") . ")");

# Update existing data in bobo.
# Careful--strings must be enclosed by ' '
$dbh->do('UPDATE bobo SET id=99 WHERE id=44');

# Retrieve and display data from bobo.
print "\n";
$qry = 'SELECT * FROM bobo WHERE id > 42 ORDER BY id';
&queryit($qry);

# Delete existing data in bobo.
$dbh->do('DELETE FROM bobo WHERE id=45');

# Retrieve and display data from bobo.
print "\n";
$qry = 'SELECT * FROM bobo';
&queryit($qry);

$dbh->disconnect();


# Retrieve and display data from bobo.
sub queryit {
  my $sqlqry = $_[0];

  $sth = $dbh->prepare($sqlqry);
  $sth->execute();
  while ( $row = $sth->fetchrow_hashref ) {
    print "Found: ", $row->{'id'}, " and ", $row->{'name'}, "\n";
  }
  $sth->finish();
}

