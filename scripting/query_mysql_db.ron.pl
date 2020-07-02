#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.ron.pl
#
#  Summary: Determine if direct matching only I or only O what the match 
#           % would be.  Requested by Ron Chamblee. 
#
#  Created: Tue 27 Aug 2002 08:39:06 (Bob Heckel)
# Modified: Thu 12 Sep 2002 10:27:28 (Bob Heckel) 
##############################################################################
use strict;
use DBI();

use constant DEBUG    => 0;
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'iando';
###use constant RAWINPUT => '/home/bqh0/tmp/BEN2PT1.noret.txt';
###use constant RAWINPUT => '/home/bqh0/tmp/nomatch.occrestrict.out';
use constant RAWINPUT => '/home/bqh0/tmp/nomatch.fuzz.out';
use constant OUTPUT   => '/home/bqh0/tmp/adhoc.out';

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );

unlink OUTPUT;  # cleanup from previous run

RunQry('ind');
RunQry('occ');

$dbh->disconnect();

exit 0;


sub RunQry {
  my $type     = shift;
  my $typelit  = $type . "literal";
  my $t        = '';
  my $tlit     = '';
  my $tliteral = '';

  ($type eq 'ind') ? ($t = 'i') : ($t = 'o');
  print "Processing $t...\n";
  $tlit = $t . 'lit';
  $tliteral = $t . 'literal';

  my $sth = $dbh->prepare("SELECT * FROM " . TBLNAME . 
                          " WHERE " . $typelit . " = ?;");

  my $numtot = 0;
  my $nummatch = 0;
  open FILE, RAWINPUT or die "Error: $0: $!";
  open RESULTSFILE, '>>'.OUTPUT || die "$0: can't open file: $!\n";
  print RESULTSFILE "\n**** Industry ****\n" if $type eq 'ind';
  print RESULTSFILE "\n**** Occupation ****\n" if $type eq 'occ';
  while ( <FILE> ) {
    if ( DEBUG ) {
      next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
      ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
      ###next unless ( $. % 200 ) == 0;
    }
    $_ =~ s/[\r\n]+$//;
    my (undef, undef, undef, undef, undef, undef, $ilit, $olit) = split "\t", $_;
    print RESULTSFILE "examining $ilit and $olit\n";
    if ( DEBUG ) {
      print "examining $ilit and $olit\n";
    }
    my %seen = ();  # reset for each rawline iteration.
    if ( $type eq 'ind' ) {
      $sth->execute(uc $ilit);
    } 
    elsif ( $type eq 'occ' ) {
      $sth->execute(uc $olit);
    }
    else {
      warn "error $type\n";
    }
    while ( my $ref = $sth->fetchrow_hashref() ) {
      if ( $type eq 'ind' ) {
        $seen{$ilit}++;
        # Only want to prove that it *can* be matched, then stop for that rawline.
        next if $seen{$ilit} > 1;
        print RESULTSFILE "I matched! $ref->{indliteral}\n";
        if ( DEBUG ) {
          print " matched! $ref->{indliteral}\n";
        }
        $nummatch++;
      }
      elsif ( $type eq 'occ' ) {
        $seen{$olit}++;
        next if $seen{$olit} > 1;
        print RESULTSFILE "O matched! $ref->{occliteral}\n";
        if ( DEBUG ) {
          print " matched! $ref->{occliteral}\n";
        }
        $nummatch++;
      }
    }
    $numtot++;
  }
  close FILE;

  $sth->finish();

  print RESULTSFILE "\t", sprintf("%.2f", $nummatch/$numtot*100), "% $type match\n";

  close RESULTSFILE;

  return 0;
}
