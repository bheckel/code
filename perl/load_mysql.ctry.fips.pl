#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql_db.pl
#
#  Summary: Load data from a file into a MySQL database.  Wipes out old 
#           table if it exists.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Tue 29 Jun 2004 13:51:44 (Bob Heckel)
##############################################################################
use strict;
use DBI;

##################Config##########################
use constant LOADFILE => 'countries.txt';
use constant DBASE    => 'fips';
use constant TBLNAME  => 'country';
use constant DEBUG    => 1;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       'bheckel', 
                       '',     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

print "Ready to load ", LOADFILE, "\nContinue? ";
<STDIN> ne "n\n" ? print "ok\n" : die "Cancelled\n";

# Drop table. This may fail, if TBLNAME doesn't exist but it doesn't matter.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Table " . TBLNAME . " is being created for the 1st time: $@\n" if $@;

# TODO input variables in the Config section
# Sample data:
# ME*SPANISH NORTH AFRICA
# Create a new table 'foo'. This must not fail, thus we don't catch errors.

$dbh->do("CREATE TABLE " . TBLNAME . 
         " (countrycode CHAR(2), flag CHAR(1), countryname CHAR(50),
            INDEX idx (countryname))"
        );

my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
my $maxl = 0;
my @fields = ();
my @all = ();

open INPUTFILE, LOADFILE or die "Error: $0: $!";
while ( <INPUTFILE> ) {
  s/[\r\n]+$//;  # chomp
  # Sample data:
  # ME*SPANISH NORTH AFRICA
  m/^(..)(.)(.*)/;
  $sth->execute("$1", "$2", "$3") or die "Can't execute with parameters @fields: $DBI::errstr";  
  # Make sure no extra long line surprises.
  ###$maxl = length($fields[2]) if $maxl < length($fields[2]);
  $maxl = length($3) if $maxl < length($3);
  $n++;
}
close INPUTFILE;

if ( DEBUG ) {
  # Retrieve test data from the table.
  $sth = $dbh->prepare("SELECT * FROM " . TBLNAME);
  $sth->execute();
  my $rownum = 0;
  while ( my $ref = $sth->fetchrow_hashref() ) {
    if ( $rownum < 20 ) {
      print "$ref->{'countrycode'}\t$ref->{'flag'}\t$ref->{'countryname'}\n";
      $rownum++;
    }
  }
}

$sth->finish();

# Disconnect from the database.
$dbh->disconnect();

print "DEBUG: maximum line length of \$field[2] is $maxl\n";
print "Finished.  $n records inserted into table " . TBLNAME .
      " on database " . DBASE . "\n";
