#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.reverse.pl
#
#  Summary: Query data, simple direct, but with I and O reversed in the hopes
#           of catching a poorly completed death cert.  Write the matches and
#           the misses to files in the reversed order that they were found in
#           the Known db.  TODO there are some seemingly wrong combos in the
#           Known db that this is successfully matching.
#
#           Sample input:
#           002150  15  15  066 1 09  CITY EMPLOYEE GENERAL
#           Sample output (if match):
#           GENERAL 77  CITY EMPLOYEE 626
#
#  Created: Thu 05 Sep 2002 08:56:49 (Bob Heckel)
# Modified: Fri 13 Sep 2002 12:28:31 (Bob Heckel) 
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
use constant TBLNAME    => 'iando';
use constant RAWINPUT   => '/home/bqh0/tmp/nomatch.exception.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.reverse.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.reverse.out';
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

# Cleanup from previous run, if any.
unlink OUTPUTFILE;
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      RAWINPUT . "\n";

my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . 
      " WHERE indliteral = ?  AND occliteral = ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME .
      ###" WHERE indliteral LIKE ? AND occliteral LIKE ?;");
###my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME .
      ###" WHERE indliteral REGEXP ? AND occliteral REGEXP ?;");

my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
open FILE, RAWINPUT or die "Error: $0: $!";
while ( <FILE> ) {
  my $gotit = 0;
  if ( DEBUG ) {
    ###next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
    ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  if ( DEBUG ) {
    print "examining $ilit and $olit\n";
  }
  ###$sth->execute(uc $olit, uc $ilit);  # reversed intentionally
  ###$olit = '^' . $olit . '.?$';
  ###$ilit = '^' . $ilit . '.?$';
  $sth->execute(uc "$olit", uc "$ilit");  # reversed intentionally
  while ( my $ref = $sth->fetchrow_hashref() ) {
    if ( DEBUG ) {
      print " matched! $ref->{indliteral} and $ref->{occliteral}\t" .
            "using raws O $olit and I $ilit\n";
    }
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
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
