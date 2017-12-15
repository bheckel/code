#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql_db.pl
#
#  Summary: Load data from a file into a MySQL database.  Wipes out old 
#           table if it exists.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
##############################################################################
use strict;
use DBI();

##################Config##########################
use constant LOADFILE => '/home/bqh0/tmp/bothbig2permute.nodup.txt';
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'iando';
use constant DEBUG    => 0;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

# perl -pi.bak -e 's/(\w+)/\U$1/g' bothbig2permute.nodup.txt
print "Make sure \n", LOADFILE, "\nhas been uppercased.  Continue? ";
<STDIN> ne "n\n" ? print "ok\n" : die "Exiting\n";

# Drop table. This may fail, if TBLNAME doesn't exist.  Thus we put an
# eval around it.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Non-fatal error while dropping " . TBLNAME . "$@\n" if $@;

# TODO input variables in the Config section
# Sample data:
# 999^I99^I99^IANIMAL HOSPITAL^ISECRETARY^I748^I570
# Create a new table 'foo'. This must not fail, thus we don't catch errors.
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (trash INTEGER, trash2 INTEGER, trash3 INTEGER,
            indliteral VARCHAR(50), occliteral VARCHAR(50),
            indnum INTEGER, occnum INTEGER,
            INDEX ioliteral (indliteral,occliteral))"
        );

# DEBUG
###$dbh->do("INSERT INTO foo VALUES (999, 99, 999, 
###         " . $dbh->quote("DIOCESE OF PROVIDENCE") . ",
###         " . $dbh->quote("MINISTER") . ", 916, 204)"
###        );
###$dbh->do("INSERT INTO foo VALUES (999, 99, 999,
###         " . $dbh->quote("DOMINICAN FATHER") . ",
###         " . $dbh->quote("CATHOLIC PRIEST") . ", 917, 205)"
###        );

my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?, ?, ?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
open INPUTFILE, LOADFILE or die "Error: $0: $!";
while ( <INPUTFILE> ) {
  chomp $_;
  $sth->execute(split "\t", $_) or 
    die "Can't execute with parameters $_: $DBI::errstr";  
  $n++;
}
close INPUTFILE;

if ( DEBUG ) {
  # Retrieve test data from the table.
  $sth = $dbh->prepare("SELECT * FROM " . TBLNAME);
  $sth->execute();
  while ( my $ref = $sth->fetchrow_hashref() ) {
    print "ind literal = $ref->{'indliteral'},  ind code = $ref->{'indnum'}\n";
  }
}

$sth->finish();

# Disconnect from the database.
$dbh->disconnect();

print "Finished.  $n records inserted into table " . TBLNAME .
      " on database " . DBASE . "\n";
