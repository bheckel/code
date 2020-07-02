#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.occunrest.pl
#
#  Summary: If Occupation has no restriction (i.e. no 123, (123), #123 in the
#           Center Restriction field) then find a natural language match on
#           Industry lit, grab its coded Ind number, and the pair should be
#           valid per the Rules.
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Thu 12 Sep 2002 09:28:47 (Bob Heckel)
##############################################################################
use strict;
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
use constant TBLNAME    => 'iando';
use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.slash.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.occunrest.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.occunrest.out';
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      INPUTFILE . "...\n";

# Cleanup previous runs, if any.
unlink OUTPUTFILE;
unlink NOMATCHF;

my $t1 = time();    # start
# Holds key occliteral, value occnum for those few unrestricted occupations.
my %FREEHASH = ();  # GLOBAL!
print FillHash(), " records inserted into hash\n";

# Normal
my $sth = $dbh->prepare(
                        "SELECT * 
                         FROM " . TBLNAME . "
                         WHERE occliteral = ?;"
                       );
# Natural lang.
my $sth2 = $dbh->prepare(
                         "SELECT *, MATCH (indliteral) AGAINST (?) AS score 
                          FROM " . TBLNAME . "
                          WHERE MATCH (indliteral) AGAINST (?) LIMIT 1;"
                        );

my $numtot   = 0;
my $nummatch = 0;
my $nummiss  = 0;
my @matchlinenums = ();
open FILE, INPUTFILE or die "Error: $0: $!";
LINE: while ( <FILE> ) {
  if ( DEBUG ) {
    ###next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
    ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
    ###next unless ( $. % 100 ) == 0;  # 8000 records so use 80 as a subset
    ###next unless ( $. % 10 ) == 0;  # 8000 records so use 800 as a subset
  }
  $_ =~ s/[\r\n]+$//;  # chomp
  # 002390^I17^I17^I081^I1^I12^IWHOLESALE^IFLORIST MANAGER
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  # I've determined 25 Occ codes that have no restrictions.  Each has been
  # combined with its literal and placed in this hash.
  while ( (my $key, my $val) = each(%FREEHASH) ) {
    next if $olit !~ /^$key$/i;  # try next if we can't match the Occ literal
    if ( DEBUG ) {
      print "looking at $key and $val\n";
      print "$.L have olit in the hash--- ilit: $ilit olit: $olit\n";
      print "now running query #1 to see if olit is in Known db (direct match)...\n";
    }
    $sth->execute(uc $olit);
    while ( my $ref = $sth->fetchrow_hashref() ) {
      if ( DEBUG ) {
        ###print "...it is, matched db's $ref->{occliteral} to hashednum $val\n";
        print "...it is, matched db's $ref->{occliteral} : $ref->{occnum}\n";
        print "now running MATCH query to find a natural match indliteral...\n";
      }
      # Run second query to find best natural language match against the ind
      # literal you found as a result of finding a magic (unrestricted) occ
      # num.
      $sth2->execute(uc $ilit, uc $ilit);
      my $inaturallit = undef;
      my $inaturalnum = undef;
      while ( my $otherref = $sth2->fetchrow_hashref() ) {
        # Query above uses LIMIT 1 to find the best score.
        print "$otherref->{score}naturalmatched $otherref->{indliteral} to $ilit\n" if DEBUG;
        $inaturallit = $otherref->{indliteral};
        $inaturalnum = $otherref->{indnum};
      }
      if ( $inaturallit && $inaturalnum ) {
        push @matchlinenums, $.;  # for writing the misses file later
        open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
        print RESULTSFILE "$inaturallit\t$ref->{occliteral}\t" .
                          "$inaturalnum\t$ref->{occnum}\n";
        close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
        $nummatch++;
      } else {
        print "\nMMMMMMMMMMMMMMISSSSSSSSSSSSSSSSSSEEEEEEDDDDDDD\n" if DEBUG;
      }
      $numtot++;
      next LINE;  # take the first Industry code you find  
    }
  }
  $numtot++;
}
close FILE;

$sth->finish();
$dbh->disconnect();

# Write the misses.
open FILE, INPUTFILE or die "Error: $0: $!"; 
INPLINE: while ( <FILE> ) {
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  foreach my $n ( @matchlinenums ) {
    next INPLINE if $n == $.;  # already decided that line was a match
  }
  open MISSFILE, '>>'.NOMATCHF || die "$0: can't open file: $!\n";
  print MISSFILE "$f1\t$f2\t$f3\t$f4\t$f5\t$f6\t$ilit\t$olit\n";
  close MISSFILE || die "cannot close MISSFILE $!\n";
  $nummiss++;
}
close FILE;

IOCODE_util::DispResult($t1, $nummatch, $nummiss, $numtot);

exit 0;


# Create a hash of occlit and occnum for those occnums we know are completely
# center unrestricted.
sub FillHash {
  my $n = 0;
  my $sth3 = $dbh->prepare("SELECT occliteral, occnum 
                            FROM " . TBLNAME . "
                            WHERE occnum = ?;");

  # Determined these 25 by Excel's Data:SubTotal feature.  At each change in
  # OCC_2000 Use Func Count Add subtot to INDRST2K, then sort on Count.  I
  # took these 25 which had a Count of zero.
  my @unrestricted = (011,070,101,102,106,123,165,
                      180,183,184,284,311,314,315,
                      316,320,321,322,323,340,362,
                      493,583,591,911);

  foreach my $onum ( @unrestricted ) {
    $sth3->execute($onum);
    while ( my $ref = $sth3->fetchrow_hashref() ) {
      $FREEHASH{$ref->{occliteral}} = $ref->{occnum};
      $n++;
    }
  }

  return $n;
}
