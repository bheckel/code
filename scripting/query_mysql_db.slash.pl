#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.slash.pl
#
#  Summary: Query data, simple direct, in a MySQL database after removing the
#           right side of slashed literals (left side if STUDENT).
#
#  Created: Thu 05 Sep 2002 16:46:58 (Bob Heckel)
# Modified: Mon 09 Sep 2002 15:45:29 (Bob Heckel) 
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
use constant TBLNAME    => 'iando';
use constant RAWINPUT   => '/home/bqh0/tmp/nomatch.reverse.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.slash.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.slash.out';
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

# Cleanup from previous run.
unlink OUTPUTFILE;
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      RAWINPUT . "\n";

my $sth = $dbh->prepare(qq/
                          SELECT * FROM @{[ TBLNAME ]} 
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
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  if ( DEBUG ) {
    print "examiningpreslashed $ilit and $olit\n";
  }
  for ( $ilit, $olit ) {
    # Rule: prefer *paid* over unpaid work.
    if ( $ilit =~ /student/i or $olit =~ /student/i ) {
      s/student\///i;
    } else {
      # Rule: chop off the word(s) after the slash to be consistent.
      s/\/.*//;
    }
  }
  if ( DEBUG ) {
    print "examiningpostslashed $ilit and $olit\n";
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
