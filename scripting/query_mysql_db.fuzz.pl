#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.fuzz.pl
#
#  Summary: Query data fuzzily in a MySQL database.  Using a
#           database-is-partitioned-into-string-lengths approach.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Thu 05 Sep 2002 17:19:25 (Bob Heckel) 
##############################################################################
use strict qw(refs vars);
use DBI();
use String::Similarity;
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
use constant DBASE      => 'indocc';
use constant TBLNAME    => 'iando';
use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.occrestrict.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.fuzz.out';
# This holds all misses from the other 7 passes.
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.fuzz.out';
use constant CONFIDENCE => '0.90';

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

unlink OUTPUTFILE;  # cleanup from previous run
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      INPUTFILE . "\n";

# Caution: If add new line here, also add another elsif in the while loop
# below.  These partitions should result in < 100,000 records each.
my $sql1 = BuildPrepare(1, 4, TBLNAME);
my $sth1 = $dbh->prepare($sql1);
my $sql5 = BuildPrepare(5, 10, TBLNAME);
my $sth5 = $dbh->prepare($sql5);
my $sql11 = BuildPrepare(11, 20, TBLNAME);
my $sth11 = $dbh->prepare($sql11);
my $sql21 = BuildPrepare(21, 25, TBLNAME);
my $sth21 = $dbh->prepare($sql21);
my $sql26 = BuildPrepare(26, 30, TBLNAME);
my $sth26 = $dbh->prepare($sql26);
my $sql31 = BuildPrepare(31, 35, TBLNAME);
my $sth31 = $dbh->prepare($sql31);
my $sql36 = BuildPrepare(36, 40, TBLNAME);
my $sth36 = $dbh->prepare($sql36);
my $sql41 = BuildPrepare(41, 45, TBLNAME);
my $sth41 = $dbh->prepare($sql41);
my $sql46 = BuildPrepare(46, 50, TBLNAME);
my $sth46 = $dbh->prepare($sql46);
my $sql51 = BuildPrepare(50, 150, TBLNAME);
my $sth51 = $dbh->prepare($sql51);

# Database entries must be uppercase!

my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
open FILE, INPUTFILE or die "Error: $0: $!";  # usually around 8000 records
while ( <FILE> ) {
  my $gotit = 0;
  if ( DEBUG ) { 
    ###next unless ( $. % 50 ) == 0;  # 8000 records so take 160 records to debug
    ###next unless ( $. % 100 ) == 0;  # 8000 records so take 80 records to debug
    ###next unless ( $. % 200 ) == 0;  # 8000 records so take 40 records to debug
    next unless ( $. % 400 ) == 0;  # 8000 records so take 20 records to debug
    ###next unless ( $. % 800 ) == 0;  # 8000 records so take 10 records to debug
    ###next unless ( $. % 2000 ) == 0;  # 8000 records so take 5 records to debug
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  my $rawfused = join ' ', $ilit, $olit;
  print " examining: $rawfused\n";
  my $rawfusedlen = length $rawfused;
  my $bestdb = undef;
  my $bestdbinum = undef;
  my $bestdbonum = undef;
  my $hiscore = 0;

  # Run 1 of n queries depending on the size of the concatenated literal.
  # Caution: These must be synchronized with the Prepares above.
  if ( $rawfusedlen >= 1 and $rawfusedlen <= 4 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth1);
  }
  elsif ( $rawfusedlen >= 5 and $rawfusedlen <= 10 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth5);
  }
  elsif ( $rawfusedlen >= 11 and $rawfusedlen <= 20 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth11);
  }
  elsif ( $rawfusedlen >= 21 and $rawfusedlen <= 25 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth21);
  }
  elsif ( $rawfusedlen >= 26 and $rawfusedlen <= 30 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth26);
  }
  elsif ( $rawfusedlen >= 31 and $rawfusedlen <= 35 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth31);
  }
  elsif ( $rawfusedlen >= 36 and $rawfusedlen <= 40 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth36);
  }
  elsif ( $rawfusedlen >= 41 and $rawfusedlen <= 45 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth41);
  }
  elsif ( $rawfusedlen >= 46 and $rawfusedlen <= 50 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth46);
  }
  elsif ( $rawfusedlen >= 51 and $rawfusedlen <= 150 ) {
    ($bestdb, $bestdbinum, $bestdbonum, $hiscore) = RunRange($rawfused, $sth51);
  }
  else {
    print "?? Out of Range: $rawfusedlen\n";
  }

  ###if ( DEBUG ) { 
    print "match best: ($rawfused)\t[$bestdb]\t$hiscore\n" if $bestdb;
    ###}

  if ( $bestdb ) {
    $nummatch++;
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    print RESULTSFILE "$bestdb\t$bestdbinum\t$bestdbonum\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
    $gotit = 1;
  }

  unless ( $gotit ) {
    open MISSFILE, '>>'.NOMATCHF || die "$0: can't open file: $!\n";
    print MISSFILE "$f1\t$f2\t$f3\t$f4\t$f5\t$f6\t$ilit\t$olit\n";
    close MISSFILE || die "cannot close MISSFILE $!\n";
    $nummiss++;
  }

  $numtot++;
}

close FILE;

$dbh->disconnect();

IOCODE_util::DispFuzzResult($t1, $nummatch, $nummiss, $numtot, NOMATCHF);
###print time-$t1, " seconds\t";
###print " ", (time-$t1) / $numtot, " seconds per line\n";
###print $nummatch / $numtot * 100, "% matched\t";
###print "$numtot seen\n";
###print "$nummatch matched\t$nummiss missed\n";
###print "See file ", NOMATCHF , " for final misses\n";
###print "Run howdo.sh to build final matches file.\n";

exit 0;


sub BuildPrepare {
  my ($hi, $lo, $tbl) = @_;

  # Widen the length of db records that get SELECTed to give fuzzy a chance to
  # make more matches.
  $hi = $hi + 1;
  $lo = $lo + 1;

  my $s =<<EOT;
SELECT CONCAT(indliteral, ' ', occliteral) AS dbfused, indnum, occnum, slen 
FROM $tbl WHERE CONCAT(indliteral, ' ', occliteral) != ?
AND slen BETWEEN $hi AND $lo
EOT

 return $s;
}


sub RunRange {
  my ($rawfused, $sth) = @_;
  my $bestdb = undef;
  my $bestdbinum = undef;
  my $bestdbonum = undef;
  my $numrowsearched = 0;

  # Raw entries must be uppercase!
  $sth->execute(uc $rawfused); 
  my $highest = 0;
  my $currscore = 0;
  while ( my $ref = $sth->fetchrow_hashref() ) {
    $currscore = similarity($rawfused, $ref->{dbfused}, CONFIDENCE);
    ###if ( DEBUG ) { 
      print "DEBUGsofar: $ref->{dbfused} is $currscore\n" if $currscore > CONFIDENCE;
      ###}
    if ( $currscore > $highest ) {
      $highest = $currscore;
      $bestdb = $ref->{dbfused};
      $bestdbinum = $ref->{indnum};
      $bestdbonum = $ref->{occnum};
    }
    $numrowsearched++;
  }
  $sth->finish();

  ###if ( DEBUG ) { 
    print "$.L partition size: $ENV{fg_blue}$numrowsearched $ENV{normal}\n";
    ###}

  if ( $highest < CONFIDENCE ) {
    return undef, undef, undef, undef;
  } else {
    return $bestdb, $bestdbinum, $bestdbonum, $highest;
  }
}
