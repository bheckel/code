#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.pl
#
#  Summary: Query data in a MySQL database.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
##############################################################################
use strict;
use DBI();
use String::Similarity;

##################Config##########################
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'iando';
use constant RAWINPUT => '/home/bqh0/tmp/BEN2PT1.noret.txt';
use constant DEBUG    => 0;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

my $t1 = time();

# Method 1:
###my $x = 'auerbach company';
###my $sql = sprintf("SELECT * FROM " . TBLNAME . " WHERE indliteral = %s;", 
                                                          ###$dbh->quote($x)); 
###my $sth = $dbh->prepare($sql);
###$sth->execute();

# Method 2:
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . " WHERE indliteral = ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . " WHERE CONCAT(indliteral, ' ', occliteral) = ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . " WHERE indliteral LIKE ?  AND occliteral LIKE ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . " WHERE indliteral LIKE ?  AND occliteral LIKE ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . " WHERE indliteral = ?");
###my $sth = $dbh->prepare("select * from iando where indliteral = 'auerbach company' and occliteral = 'buYER';");
###$sth->execute('auerbach company', 'buyer');
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . 
                                                          ###" WHERE indliteral = ?  AND occliteral = ?;");
my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . 
                        " WHERE indliteral != ?  AND occliteral != ?;");

my $numtot = 0;
my $nummatch = 0;
open FILE, RAWINPUT or die "Error: $0: $!";
while ( <FILE> ) {
  # DEBUG
  next unless ( $. % 2000 ) == 0;
  $_ =~ s/[\r\n]+$//;
  my (undef, undef, undef, undef, undef, undef, $ilit, $olit) = split "\t", $_;
  print "DEBUG: examining $ilit and $olit\n";
  # Not sure if case-insensitive search by MySQL or Perl so assume database is
  # uppercase.
  $sth->execute(uc $ilit, uc $olit);
  ###$sth->execute(uc $ilit . '.*', uc $olit . '.*');
  while ( my $ref = $sth->fetchrow_hashref() ) {
    ###print "dematch: ind = $ref->{indliteral},  ind code = $ref->{indnum}\t";
    ###print "occ = $ref->{occliteral},  occ code = $ref->{occnum}\n";
    my $x = similarity $ilit, $ref->{indliteral};
    print "ssim of $ilit: $x\n" if $x > 0.90;
    $nummatch++;
  }
  $numtot++;
}
close FILE;

$sth->finish();

$dbh->disconnect();

my $t2 = time();
print $t2 - $t1, " seconds\t";
print $nummatch / $numtot * 100, "% matched\n";
