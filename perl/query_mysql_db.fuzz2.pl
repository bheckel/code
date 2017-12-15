#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.fuzz2.pl
#
#  Summary: Query data fuzzily in a MySQL database.
#           Look at the raw concatenated Ind and Occ literal, try to
#           natural language match the db's concatenated Ind and Occ literals.
#           MySQL does a bad job of natural matching *but* if used as input
#           for String::Similarity comparisons, it might be accurate enough
#           and much faster than the partitioned database approach.
#
#  Created: Fri 13 Sep 2002 13:53:25 (Bob Heckel)
##############################################################################
use strict qw(refs vars);
use DBI();
use String::Similarity;
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 1;
use constant TBLNAME    => 'iando';
use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.occrestrict.out';
###use constant INPUTFILE  => '/home/bqh0/tmp/smallBENtest.txt';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.fuzz.out';
# This holds all misses from the other 7 passes.
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.fuzz.out';
use constant CONFIDENCE => '0.90';
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

# Cleanup from previous run.
unlink OUTPUTFILE;  
unlink NOMATCHF;
my $t1 = time();
my $load1 = IOCODE_util::AvgLoad;

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      INPUTFILE . "\n";

# Natural language search.
my $sth = $dbh->prepare(qq/
                          SELECT CONCAT(indliteral, ' ', occliteral) AS 
                                                    dbfused, indnum, occnum 
                          FROM @{[ TBLNAME ]}
                          WHERE MATCH (indliteral, occliteral) AGAINST (?)
                        /);

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
    ###next unless ( $. % 400 ) == 0;  # 8000 records so take 20 records to debug
    ###next unless ( $. % 800 ) == 0;  # 8000 records so take 10 records to debug
    ###next unless ( $. % 2000 ) == 0;  # 8000 records so take 5 records to debug
  }
  $_ =~ s/[\r\n]+$//;  # chomp
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  my $rawfused = join ' ', $ilit, $olit;
  print "examining rawfused: $rawfused\n";
  # The Known Master db should not have any "(blank) FOO" entries so save some
  # time by skipping.
  if ( !$ilit or !$olit ) {
    print "skipping (no ilit): $rawfused\n" if !$ilit;
    print "skipping (no olit): $rawfused\n" if !$olit;
    $numtot++ && $nummiss++;
    next;
  }
  my $hiscore = 0;
  my $currscore = 0;
  my $bestdb = undef; my $bestdbinum = 0; my $bestdbonum = 0;
  $sth->execute(uc $rawfused);
  # Arrays run faster than hashes (at the expense of clarity).
  ###while ( my $ref = $sth->fetchrow_hashref() ) {
  while ( my $ref = $sth->fetchrow_arrayref() ) {
    ###$currscore = similarity($rawfused, $ref->{dbfused}, CONFIDENCE);
    $currscore = similarity($rawfused, $ref->[0], CONFIDENCE);
    ###print "CANDIDATE: $ref->{dbfused} is $currscore\n" if $currscore > CONFIDENCE;
    print "CANDIDATE: $ref->[0] is $currscore\n" if $currscore > CONFIDENCE;
    if ( $currscore > $hiscore ) {
      $hiscore = $currscore;
      ###$bestdb = $ref->{dbfused};
      $bestdb = $ref->[0];
      ###$bestdbinum = $ref->{indnum};
      $bestdbinum = $ref->[1];
      ###$bestdbonum = $ref->{occnum};
      $bestdbonum = $ref->[2];
    }
  }
  if ( $hiscore >= CONFIDENCE) {
    $gotit = 1;
    $nummatch++;
    print "$ENV{fg_yellow}BEST$ENV{normal}> $hiscore $bestdb is $bestdbinum and $bestdbonum  $ENV{fg_yellow}<BEST$ENV{normal}\n";
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    print RESULTSFILE "$rawfused\t$bestdbinum\t$bestdbonum\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
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

IOCODE_util::DispFuzzResult($t1, $nummatch, $nummiss, $numtot, NOMATCHF, 
                            $load1);
