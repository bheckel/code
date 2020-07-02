#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.direct.pl
#
#  Summary: Query data, simple direct, in a MySQL database and write the
#           matches to a file.
#
#           Assumes RAWINPUT has manually (too random and often changing to do
#           programmatically) had: 
#           * The header line deleted.
#           * Thousands of blank lines at bottom deleted. 
#           * Garbage after Occ lit removed with vi :%s:^I\{3,}.*$::gc
#             (careful with this one, must confirm each one) 
#           * Entire file uppercased to match database via :%s/\(.*\)/\U\1/gc
#
#           Sample input:
#           000001^I03^I03^I020^I1^I13^IEDUCATION^ISTUDENT
#           Sample output (if match):
#           OWN HOME^I989^IHOUSEWIFE^I901
#           Sample output (if no match) passed to next query:
#           000900^I01^I01^I070^I1^I09^ICONCRETE PLANT^IFOREMAN 
#
#           if this input layout changes, must adjust the split() below, if
#           the output layout changes, must adjust the print() below.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Thu 05 Sep 2002 09:57:54 (Bob Heckel)
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 1;
use constant TBLNAME    => 'iando';
###use constant RAWINPUT   => '/home/bqh0/tmp/BEN2PT1.clean.txt';
###use constant RAWINPUT   => '/home/bqh0/tmp/smallBENtest.txt';
use constant RAWINPUT   => '/home/bqh0/tmp/junk';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.direct.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.direct.out';
##################Config##########################


my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

unlink OUTPUTFILE;  # cleanup from previous run
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      RAWINPUT . "\n";

my $sth = $dbh->prepare(qq/
                          SELECT * 
                          FROM @{[ TBLNAME ]} 
                          WHERE indliteral = ? AND occliteral = ?
                        /);

my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
open FILE, RAWINPUT or die "Error: $0: $!";
while ( <FILE> ) {
  my $gotit = 0;
  if ( DEBUG ) {
    ###next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
    ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
    ###next unless ( $. % 50 ) == 0;
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  if ( DEBUG ) {
    print "examining $ilit and $olit\n";
  }
  $sth->execute(uc $ilit, uc $olit);
  while ( my $ref = $sth->fetchrow_hashref() ) {
    if ( DEBUG ) {
      print " matched! $ref->{indliteral} and $ref->{occliteral}\n";
    }
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    if ( DEBUG ) {
      print RESULTSFILE "examining $ilit and $olit\n";
    }
    print RESULTSFILE "$ref->{indliteral}\t$ref->{indnum}\t" .
                      "$ref->{occliteral}\t$ref->{occnum}\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
    $gotit = 1;
    $nummatch++;
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

$sth->finish();

$dbh->disconnect();

IOCODE_util::DispResult($t1, $nummatch, $nummiss, $numtot);
