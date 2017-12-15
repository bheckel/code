#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.minor.pl
#
#  Summary: Query data in a MySQL database and write the matches and misses 
#           to files.  This cleans up things like RETIRED, quotes, etc.
#
#  Created: Thu 05 Sep 2002 10:08:54 (Bob Heckel)
# Modified: Thu 18 Sep 2003 10:19:30 (Bob Heckel)
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 1;
use constant TBLNAME    => 'iando';
use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.direct.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.minor.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.minor.out';
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

# Cleanup from previous run.
unlink OUTPUTFILE;
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      INPUTFILE . "\n";

my $sth = $dbh->prepare(qq/
                          SELECT * FROM @{[ TBLNAME ]}
                          WHERE indliteral = ?  AND occliteral = ?
                         /);

my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
open FILE, INPUTFILE or 
     die "INPUTFILE error in $0 if prior step Direct Match was not 100%: $!";
while ( <FILE> ) {
  my $gotit = 0;
  if ( DEBUG ) {
    ###next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
    ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  print "***\n" if DEBUG;
  print "before minor adj: $ilit and $olit\n" if DEBUG;
  my $icache = $ilit; my $ocache = $olit;
  # These may have been handled by the fuzzy pass but this is much faster.
  for ( $ilit, $olit ) {
    # TODO if ^RETIRED$ is the only Ind and can't determine Ind from the Occ,
    # rules say to code Ind as RETIRED.  This subverts that rule unless
    # RETIRED is only *part* of the string.
    s/\s?-?\(?retired?\)?\s?-?\s?//i;  # elim dashes, parens and spaces
    ###s#\s?/?\(?retired?\)?\s?/?\s?##i;  # elim slashes TODO not working
    s/\s?-?\(ret\.?\)\s?-?\s?//i;      # must be parenthesized
    s/dept\./DEPARTMENT/i;
    s/labor person\./LABORER/i;
    s/\s+person\.$//i;
    s/^industry$//i;           # e.g. food industry s/b food
    s/^private$//i;
    s/co\.?$//i;
    s/\s{2,}/ /g;              # compress internal spaces
    s/^\s+//g;                 # compress leading spaces
    s/\s+$//g;                 # compress trailing spaces
    s/"|'//g;
    s/\s+-+\s+/ /g;             # e.g. SELF-EMPLOYED becomes SELF EMPLOYED
  }
  if ( DEBUG && ($icache ne $ilit) || ($ocache ne $olit) ) {
    print "!!! modification performed !!!\n";
  }
  print "after minor adj: $ilit and $olit\n" if DEBUG;
  print "***\n" if DEBUG;
  # CHANGED DESIGN, BLANK IN OUTPUT CONVEYS MORE INFO THAN THIS FORCE WOULD.
  # Now that spurious dashes, etc. are gone, handle I or O missing (or ones we
  # have made missing):
  # Per Instruction Manual Pt. 19 (pg. 59) Rules:
###  $ilit = 'HOMEMAKER' if ( !$ilit && ($olit eq 'HOMEMAKER') );
###  $ilit = 'BOOKEEPER' if ( !$ilit && ($olit eq 'BOOKEEPER') );
###  $ilit = 'CARPENTER' if ( !$ilit && ($olit eq 'CARPENTER') );
###  $ilit = 'SECRETARY' if ( !$ilit && ($olit eq 'SECRETARY') );
###  $ilit = 'DOMESTIC' if ( !$ilit && ($olit eq 'DOMESTIC') );
###  $ilit = 'DOMESTIC' if ( !$ilit && ($olit eq 'DOMESTIC') );
###  $ilit = 'HOUSEWIFE' if ( !$ilit && ($olit eq 'HOUSEWIFE') );
###  $ilit = 'INFANT' if ( !$ilit && ($olit eq 'INFANT') );
###  $ilit = 'CHILD' if ( !$ilit && ($olit eq 'CHILD') );
###
###  $olit = 'DEPOT' if ( !$olit && ($ilit eq 'SECRETARY') );
###  $olit = 'HOMEMAKER' if ( !$olit && ($ilit eq 'HOMEMAKER') );
###  $olit = 'HOUSEWIFE' if ( !$olit && ($ilit eq 'HOUSEWIFE') );
###  $olit = 'SELF EMPLOYED' if ( !$olit && ($ilit eq 'SELF EMPLOYED') );
###  $olit = 'WIRE' if ( !$olit && ($ilit eq 'WIRE') );
###  $olit = 'INFANT' if ( !$olit && ($ilit eq 'INFANT') );
###  $olit = 'CHILD' if ( !$olit && ($ilit eq 'CHILD') );

  ###print "examining cleanedup $ilit and $olit\n" if DEBUG;
  $sth->execute(uc $ilit, uc $olit);
  while ( my $ref = $sth->fetchrow_hashref() ) {
    if ( DEBUG ) {
      ###print " matched! $ref->{indliteral} and $ref->{occliteral}\n";
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
