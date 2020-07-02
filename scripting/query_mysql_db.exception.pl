#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.exception.pl
#
#  Summary: Find blank, n/a, unknown, etc. and hardcode to 999 990 if 
#           age >= 14, else 989 910.  Find never worked, n.s., etc. and
#           hardcode to 989 910.
#
#           Don't need the Known Master db for this query since certain
#           combinations can be determined without lookup.  They will receive
#           989 910 or 999 990 automatically.
#
#  Created: Thu 05 Sep 2002 10:08:54 (Bob Heckel)
# Modified: Mon 16 Sep 2002 16:13:16 (Bob Heckel) 
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
use constant RAWINPUT   => '/home/bqh0/tmp/nomatch.minor.out';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.exception.out';
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.exception.out';
##################Config##########################
                      #
# Cleanup from previous run.
unlink OUTPUTFILE;
unlink NOMATCHF;
my $t1 = time();

print "Creating " . OUTPUTFILE . " and\n" . NOMATCHF . " from\n" . 
      RAWINPUT . "\n";

my $numtot = 0;
my $nummatch = 0;
my $nummiss = 0;
open FILE, RAWINPUT or die "Error: $0: $!";
while ( <FILE> ) {
  my $found_exception = 0;
  my $didnotwork = 0;  # did not EVER work
  if ( DEBUG ) {
    ###next unless ( $. % 1000 ) == 0;  # 8000 records so use 8 as a subset
    ###next unless ( $. % 500 ) == 0;  # 8000 records so use 16 as a subset
  }
  $_ =~ s/[\r\n]+$//;
  my ($f1, $f2, $f3, $age, $f5, $f6, $ilit, $olit) = split "\t", $_;
  if ( $age ) {
    $age =~ s/^0+(\d+)/$1/;  # avoid leading zeros that interpret as octal
  } else {
    $age = -1  # avoid error when comparing
  }
  # Ind literal or Occ literal may be missing.  This if-loop checks all
  # possible combinations.
  if ( !$ilit && !$olit ) {
    $found_exception++;
    print "AAAAAAAAAAAAAAAAA\n" if DEBUG;
  }
  # TODO optimize this mess
  elsif ( $ilit =~ m/^unknown|^unk$|^n[\/.]?a[\/.]?$|^classified|^refused|^not working/i && 
          $olit =~ m/^unknown|^unk$|^n[\/.]?a[\/.]?$|^classified|^refused|^not working/i ) {
    print "BBBBBBBBBBBBBBBBB $ilit $olit\n" if DEBUG;
    $found_exception++;
  }
  elsif ( !$ilit && 
          $olit =~ m/^unknown|^unk$|^n[\/.]?a[\/.]?$|^classified|^refused|^not working/i ) {
    print "CCCCCCCCCCCCCCCCC $ilit $olit\n" if DEBUG;
    $found_exception++;
  }
  elsif ( $ilit =~ m/^unknown|^unk$|^n[\/.]?a[\/.]?$|^classified|^refused|^not working/i && 
          !$olit ) {
    print "DDDDDDDDDDDDDDDDD $ilit $olit\n" if DEBUG;
    $found_exception++;
  }
  elsif ( $ilit =~ m/^never worked|^none|^inmate|^n\.s\.|^patient|^retarded|^disabled/i && 
          !$olit ) {
    print "EEEEEEEEEEEEEEEEE $ilit $olit\n" if DEBUG;
    $found_exception++;
    $didnotwork++;
  }
  elsif ( !$ilit && 
          $olit =~ m/^never worked|^none|^inmate|^n\.s\.$|^patient|^retarded|^disabled/i ) {
    print "FFFFFFFFFFFFFFFFF $ilit $olit\n" if DEBUG;
    $found_exception++;
    $didnotwork++;
  }
  elsif ( $ilit =~ m/^child|^infant/i && 
          !$olit ) {
    print "GGGGGGGGGGGGGGGGGG$ilit $olit\n" if DEBUG;
    # Validate that it is a child based on age reported.
    # Using three digit age rules.  See Instruction Manual Pt. 4
    # Younger than 14 is too young to have ever worked, per the I&O Rules.
    if ( $age > 0 && $age < 14 ) {
      $found_exception++;
      $didnotwork++;
    }
    # Infant units.
    if ( $age > 200 && $age < 700 ) {
      $found_exception++;
      $didnotwork++;
    }
  }
  elsif ( !$ilit && 
          $olit =~ m/^child|^infant/i ) {
    print "HHHHHHHHHHHHHHHHHH$ilit $olit\n" if DEBUG;
    if ( $age > 0 && $age < 14 ) {
      $found_exception++;
      $didnotwork++;
    }
    if ( $age > 200 && $age < 700 ) {
      $found_exception++;
      $didnotwork++;
    }
  }

  # It's an unknown or a never worked.
  if ( $found_exception ) {
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    print "foundraw $ilit\t$olit\t$age\n" if DEBUG;
    if ( $didnotwork ) {  # did not work EVER
      print RESULTSFILE "$ilit\t989\t$olit\t910\n";
    } else {  # unknowns and not workings
      print RESULTSFILE "$ilit\t999\t$olit\t990\n";
    }
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
    $nummatch++;
  } else {
    open MISSFILE, '>>'.NOMATCHF || die "$0: can't open file: $!\n";
    print MISSFILE "$f1\t$f2\t$f3\t$age\t$f5\t$f6\t$ilit\t$olit\n";
    close MISSFILE || die "cannot close MISSFILE $!\n";
    $nummiss++;
  }
  $numtot++;
}
close FILE;

IOCODE_util::DispResult($t1, $nummatch, $nummiss, $numtot);
