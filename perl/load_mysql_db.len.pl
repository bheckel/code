#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql_db.pl
#
#  Summary: Load data from a file into a MySQL database.  Uses indexes and
#           fulltext features.  Wipes out old table if it exists.
#
#          mysql> desc iando;
#   +------------+--------------------------+------+-----+---------+-------+
#   | Field      | Type                     | Null | Key | Default | Extra |
#   +------------+--------------------------+------+-----+---------+-------+
#   | age        | smallint(6)              | YES  |     | NULL    |       |
#   | education  | smallint(6)              | YES  |     | NULL    |       |
#   | residence  | smallint(6)              | YES  |     | NULL    |       |
#   | indliteral | varchar(80)              | YES  | MUL | NULL    |       |
#   | occliteral | varchar(80)              | YES  | MUL | NULL    |       |
#   | indnum     | int(3) unsigned zerofill | YES  |     | NULL    |       |
#   | occnum     | int(3) unsigned zerofill | YES  |     | NULL    |       |
#   | slen       | smallint(6)              | YES  |     | NULL    |       |
#   +------------+--------------------------+------+-----+---------+-------+
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Thu 12 Sep 2002 15:23:49 (Bob Heckel)
##############################################################################
use strict;
use DBI();

##################Config##########################
use constant LOADFILE => '/home/bqh0/tmp/bothbig2permute.nodup.txt';
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'iando';

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'PrintError' => 1, 'RaiseError' => 0}
                      );
##################Config##########################

# Assumes:
# $ perl -pi.bak -e 's/(\w+)/\U$1/g' bothbig2permute.nodup.txt
print "Make sure \n", LOADFILE, "\nhas been uppercased.  Continue? ";
<STDIN> ne "n\n" ? print "ok\n" : die "Exiting\n";

my $t1 = time();

# Drop table. This may fail, if TBLNAME doesn't exist.  Thus we put an
# eval around it.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Non-fatal error while dropping " . TBLNAME . "$@\n" if $@;

# TODO input variables in the Config section
# Sample data:
# 999^I99^I99^IANIMAL HOSPITAL^ISECRETARY^I748^I570
# TODO add indexes later?
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (age SMALLINT, education SMALLINT, residence SMALLINT,
            indliteral VARCHAR(80), 
            occliteral VARCHAR(80),
            indnum INT(3) ZEROFILL, 
            occnum INT(3) ZEROFILL,
            slen SMALLINT,
            UNIQUE (indliteral, occliteral),
            INDEX (indliteral),
            INDEX (occliteral),
            INDEX (indliteral,occliteral),
            FULLTEXT (indliteral,occliteral))"
        );

my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
my %seen = ();
print "Inserting into database...";
open INPUTFILE, LOADFILE or die "Error: $0: $!";
while ( <INPUTFILE> ) {
  $_ =~ s/[\r\n]+$//;  # chomp
  $_ =~ s/é/E/g;       # change CAFé
  my ($junk1, $junk2, $junk3, $ilit, $olit, $inum, $onum) = split "\t", $_;
  my $bothlit = $ilit . '|' . $olit;
  my $ilen = length $ilit;
  my $olen = length $olit;
  my $bothlen = $ilen + $olen;
  $seen{$bothlit}++;
  if ( $seen{$bothlit} < 2 ) {  # want uniques only
    $sth->execute($junk1, $junk2, $junk3, $ilit, $olit, $inum, $onum, $bothlen) 
                        or die "Can't execute with parameters $_: $DBI::errstr";  
    $n++;
  } else {
    print "skipped dup: $bothlit\n";
  }
}
close INPUTFILE;
$sth->finish();

print "...finished.  $n records inserted into table " . TBLNAME .
      " on database " . DBASE . "\n";

# Verify success by retrieving test data from the table.
my $sth2 = $dbh->prepare("SELECT * FROM " . TBLNAME . " LIMIT 10");
$sth2->execute();
print "Testing a few rows...\n";
while ( my $ref = $sth2->fetchrow_hashref() ) {
  print "ind literal = $ref->{'indliteral'},  ind code = $ref->{'indnum'}\n";
  print "occ literal = $ref->{'occliteral'},  occ code = $ref->{'occnum'}\n";
}

$sth2->finish();

$dbh->disconnect();

print "took ", time()-$t1, " seconds.\n";
print "Now run update query to add and/or fix known records.\n";
