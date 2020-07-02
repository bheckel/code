#!/usr/bin/perl -w
##############################################################################
#     Name: convert2k.pl
#
#  Summary: Convert 1990 I&O codes to 2000 codes.
#
#  Created: Wed 21 Aug 2002 09:27:48 (Bob Heckel)
##############################################################################
use strict;

my %ih = ();  # industry
my %oh = ();  # occupation


# Create mapping dictionaries.

open IDICT, "INDXWALK.txt" or die "$0: can't open file: $!\n";
while ( <IDICT> ) { 
  # DEBUG
  ###next unless ( $. % 4 ) == 0;
  chomp $_;
  my (undef, $oldcode, $newcode) = split / /, $_;
  $oldcode =~ s/[-¢p\+]//g;  # remove Census' Crosswalk metadata
  # If there are multiple codes (e.g. 123p), I only map the last one.
  $ih{$oldcode} = $newcode;
}
close IDICT;

# DEBUG
###print $h{'471'} if defined $h{'471'};

open ODICT, "OCCXWALK2.txt" or die "$0: can't open file: $!\n";
while ( <ODICT> ) { 
  chomp $_;
  my ($oldocode, $newocode) = split "\t", $_;
  # If there are multiple codes (e.g. 123p), I only map the last one.
  $oh{$oldocode} = $newocode;
}
close ODICT;


my $convertcnt = 0;  # total successfully converted
my $dropcnt = 0;     # dropped due to no mapping
open OUTFILE, ">./inputknown/paired.2k.txt" or die "$0: can't open file: $!\n";

# Turn 1990 codes into 2000 and write a new file.
open PAIRS, "./inputknown/paired.cleanoldnum.txt" or die "$0: can't open file: $!\n";
while ( <PAIRS> ) { 
  # DEBUG
  # 50K+ file so do 5 lines.
  ###next unless ( $. % 10000 ) == 0;
  chomp $_;
  my (undef, undef, undef, $indlit, $occlit, $indnum, $occnum) = 
                                                              split "\t", $_;

  my $pairsfh = select(OUTFILE);

  # DEBUG
  ###print OUTFILE "before: 999\t99\t99\t$indlit\t$occlit\t$indnum\t$occnum\n";
  ###print OUTFILE "after: 999\t99\t99\t$indlit\t$occlit\t$ih{$indnum}\t$oh{$occnum}\n";

  # Must have a valid mapping (old code must exist in INDXWALK.txt and
  # OCCXWALK2.txt) or we have to drop the record.
  if ( defined $ih{$indnum} && defined $oh{$occnum} ) {
    # Assuming the 1st 3 fields are garbage so fill with 9's.
    print OUTFILE "999\t99\t99\t$indlit\t$occlit\t$ih{$indnum}\t$oh{$occnum}\n";
    $convertcnt++;
  } else {
    if ( !defined $ih{$indnum} ) {
      print STDOUT "dropping: $indlit\t$occlit\t??$indnum??\t$occnum\n";
    } else {  # $oh{$occnum} is not defined
      print STDOUT "dropping: $indlit\t$occlit\t$indnum\t??$occnum??\n";
    }
    $dropcnt++;
  }
  select($pairsfh);
}
close PAIRS;

close OUTFILE;

print "Results:\n";
print "\nconverted total lines: $convertcnt\tdropped total: $dropcnt\n";
print "total lines seen: ", $convertcnt + $dropcnt;
print "\tsuccess ratio: ", $convertcnt / ($convertcnt+$dropcnt), "\n";

