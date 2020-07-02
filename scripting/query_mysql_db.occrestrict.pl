#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.occrestrict.pl
#
#  Summary: Approximately 450 Occ literals are restricted to a specific Ind
#           code regardless of what the Ind literal is ( # or () ).
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Wed 04 Sep 2002 17:07:45 (Bob Heckel) 
##############################################################################
use strict;
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
# The Alphabetical Index for Occupations.
use constant TBLOCCXLS  => 'occxls';  # created using OCC.XLS
use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.occunrest.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.occrestrict.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.occrestrict.out';

###my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
###                       "bqh0", 
###                       "",     # MySQL pw
###                       {'RaiseError' => 1}
###                      );
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%rerr);

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
       INPUTFILE . "\n";

unlink OUTPUTFILE;
unlink NOMATCHF;

my $t1 = time();

my $sth = $dbh->prepare("SELECT literal, restriction, occnum
                         FROM " . TBLOCCXLS . " 
                         WHERE literal = ?
                         AND (restriction LIKE '#___'
                              OR restriction LIKE '(%)');");
my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
my @matchlinenums = ();
open FILE, INPUTFILE or die "Error: $0: $!";
LINE: while ( <FILE> ) {
  if ( DEBUG ) { 
    ###next unless ( $. % 1000 ) == 0;  # 4000 records so use 4 as a subset
    ###next unless ( $. % 500 ) == 0;  # 4000 records so use 8 as a subset
    ###next unless ( $. % 250 ) == 0;  # 4000 records so use 16 as a subset
    ###next unless ( $. % 125 ) == 0;  # 4000 records so use 32 as a subset
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  if ( DEBUG ) { 
    print "$.L examining $ilit and $olit\n";
  }
  $sth->execute(uc $olit);
  # Try to match Occ literal.
  while ( my $ref = $sth->fetchrow_hashref() ) {
    if ( $ref->{restriction} =~ m/[)(]/ ) {  # it's a parentheses Rule
      # Rule says we can derive indlit only if indlit has *not* been supplied.
      next if $ilit;  
    }
    push @matchlinenums, $.;  # for writing the misses file later
    # Ind literal is irrelevant; you've coded it properly via I&O Rules.
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    if ( DEBUG ) { 
      print "matched! writing $ilit\t$ref->{literal}\t" .
            "$ref->{restriction}\t$ref->{occnum}\n";
      print RESULTSFILE "examining $.L $ilit and $olit\n";
    }
    my $cleaned_restr = $ref->{restriction};
    $cleaned_restr =~ s/[)#(]//g unless DEBUG;  # remove indicators
    ###print RESULTSFILE "$ilit\t$ref->{literal}\t" .
    ###"$cleaned_restr\t$ref->{occnum}\n";
    print RESULTSFILE "$ilit\t$olit\t" .
                      "$cleaned_restr\t$ref->{occnum}\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
    $nummatch++;
    $numtot++;
    next LINE;
  }
  $numtot++;  # missed
}
close FILE || die "cannot close FILE $!\n";

$sth->finish();

$dbh->disconnect();

# Write misses file.
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
close FILE || die "cannot close FILE $!\n";

IOCODE_util::DispResult($t1, $nummatch, $nummiss, $numtot);
