#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql.state.fips.pl
#
#  Summary: Load data from a fixed width file into a MySQL database.  
#           Wipes out old table if it exists.
#
#           Assumes database is ready (and possibly empty):
#           $ mysql -u root
#           create database fips;
#           grant all on fips.* to bheckel@localhost;
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Mon 07 Jun 2004 13:25:42 (Bob Heckel)
##############################################################################
use strict;
use DBI();

##################Config##########################
use constant LOADFILE => 'states.txt';
use constant DBASE    => 'fips';
use constant TBLNAME  => 'state';
use constant DEBUG    => 1;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       'bheckel', 
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
# AL01Alabama              
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (statecode CHAR(2), 
            statename CHAR(22),
            INDEX idx(statecode))"
        );

# Must have the same number of '?' as fields in the db to be created.
my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
my $maxl = 0;
my @fields = ();

open FIXEDWID, LOADFILE or die "Error: $0: $!";
while ( <FIXEDWID> ) {
  s/[\r\n]+$//;  # chomp
  m/^(..)..(.*)/;
  $sth->execute("$1", "$2") or 
                 die "Can't execute with parameters @fields: $DBI::errstr";  
  # Make sure no extra long line surprises.
  $maxl = length($2) if $maxl < length($2);
  $n++;
}
close FIXEDWID;

if ( DEBUG ) {
  # Retrieve test data from the table.
  print "sample from db just created:\n";
  $sth = $dbh->prepare('SELECT * FROM ' . TBLNAME . ' LIMIT 10');
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
}

print "Finished.  $n records inserted into table " . TBLNAME .
      " on database " . DBASE . "\n";
if ( DEBUG ) {
  print "Num recs per wc(1):\n"; 
  system('wc -l ' . LOADFILE);
}
