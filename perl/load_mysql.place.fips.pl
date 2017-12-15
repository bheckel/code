#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql.place.fips.pl
#
#  Summary: Load data from a fixed width file into a MySQL database.  
#           Wipes out old table if it exists.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Wed 11 Feb 2004 10:51:20 (Bob Heckel)
##############################################################################
use strict;
use DBI();

##################Config##########################
use constant LOADFILE => 'fips0402';
use constant DBASE    => 'fips';
use constant TBLNAME  => 'place';
use constant DEBUG    => 1;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       'bqh0', 
                       '',     # MySQL pw
                       {'RaiseError' => 1}
                      );
# For now, must also adjust the $dbh->do(... line
# and the regex that splits the dataline below.
##################Config##########################

print 'Ready to load ' . LOADFILE . "\n";
print "Existing table will be dropped (if it exists).\nContinue [y/n]? ";
<STDIN> ne "n\n" ? print "ok\n" : die "Cancelled\n";

# Drop table. This may fail if TBLNAME doesn't exist but it doesn't matter.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Table " . TBLNAME . " is being created for the 1st time: $@\n" if $@;

# TODO input SQL datatypes in the Config section instead of here
# Sample data:
# 01ALAlexander City                                      01132Tallapoosa 123C1
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (statecode CHAR(2), 
            placename CHAR(52),
            placecode CHAR(5),
            cityname CHAR(22),
            citycode CHAR(5),
            class CHAR(2),
            popflag CHAR(1),
            INDEX idx(placename))"
        );

# Must have the same number of '?' as fields in the db to be created.
my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?, ?, ?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
my $maxl = 0;
my @fields = ();

open FIXEDWID, LOADFILE or die "Error: $0: $!";
while ( <FIXEDWID> ) {
  s/[\r\n]+$//;  # chomp
  # Sample data:
  # 01ALAlexander City                                      01132Tallapoosa 123C1
  m/^..(..)(....................................................)(.....)(......................)(...)(..)(.)/;
  $sth->execute("$1", "$2", "$3", "$4", "$5", "$6", "$7") or 
                 die "Can't execute with parameters @fields: $DBI::errstr";  
  # Make sure no extra long line surprises.
  $maxl = length($2) if $maxl < length($2);
  $n++;
}
close FIXEDWID;

if ( DEBUG ) {
  # Retrieve test data from the table.
  $sth = $dbh->prepare('SELECT * FROM ' . TBLNAME . ' LIMIT 15');
  $sth->execute();
  while ( my @arr = $sth->fetchrow_array() ) {
    print "@arr\n";
  }
}

$sth->finish();

$dbh->disconnect();

if ( DEBUG ) {
  print "DEBUG: maximum line length of \$maxl is $maxl\n";
  print "DEBUG: That number should be lower than your CHAR(nn) line\n\n";
  print "May have to edit input data by hand and run again if get\n";
  print "'Use of uninitialized value in string at...' errors\n\n";
}

print "Finished.  $n records inserted into table " . TBLNAME .
      " on database " . DBASE . "\n";
if ( DEBUG ) {
  print "Num recs per wc(1):\n"; 
  system('wc -l ' . LOADFILE);
}
