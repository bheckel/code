#!/usr/bin/perl -w
##############################################################################
#     Name: convert2k.121.pl
#
#  Summary: Convert 1990 I&O codes to 2000 codes but ignore any mapping that
#           is not one to one.  Brenda request.
#
#  Created: Wed 21 Aug 2002 09:27:48 (Bob Heckel)
# Modified: Thu 22 Aug 2002 09:15:51 (Bob Heckel)
##############################################################################
use strict;

my %ih = ();  # industry
my %oh = ();  # occupation


# Create mapping dictionaries.

open IDICT, "../INDXWALK.txt" or die "$0: $!";
while ( <IDICT> ) { 
  # DEBUG
  ###next unless ( $. % 4 ) == 0;
  chomp $_;
  # Sample line (note leading space):
  #  842 786 Elementary and secondary schools
  my (undef, $oldcode, $newcode) = split / /, $_;
  # Ind Census Crosswalk give indicator 'p' for 1-to-many codes.
  next if $oldcode =~ m/p/;    # skip it, can't be sure what's best
  next if $oldcode !~ m/\d+/;  # skip it, only want codes
  next if $newcode !~ m/\d+/;
  $oldcode =~ s/[-¢\+]//g;     # remove Census' Crosswalk metadata
  $ih{$oldcode} = $newcode;    # only capture one-to-one crosswalk
}
close IDICT;


# Preparse Occ for unique old codes only.
my %seen = ();
open ODICT, "../OCCXWALK2.txt" or die "$0: $!";
while ( <ODICT> ) { 
  chomp $_;
  # Sample line:
  # 859^I973^IShuttle Car Operators
  my ($oldocode, $newocode) = split "\t", $_;
  $seen{$oldocode}++ if $oldocode;
  $oh{$oldocode} = $newocode;
}
close ODICT;

while ( (my $occnumb, my $numappear) = each(%seen) ) {
  if ( $numappear > 1 ) {  # only want one appearance for that 1990 code.
    # DEBUG
    ###print "$occnumb=$numappear\t";
    delete $oh{$occnumb};
    # DEBUG
    ###print "$oh{$occnumb}\n";
  }
}


# We now have an Ind hash of unique 1990 keys and 2000 values and an Occ hash
# of unique 1990 keys and 2000 values.


my $convertcnt = 0;  # total successfully converted
my $dropcnt = 0;     # dropped due to no mapping
open OUTFILE, ">paired.converted.exact.txt" or die "$0: $!";

# Open the old (but cleaned up a bit) 1990 file that Sam used.
open PAIRS, "../inputknown/paired.cleanoldnum.txt" or die "$0: $!";
while ( <PAIRS> ) { 
  # DEBUG
  # 50K+ file so do 5 lines.
  ###next unless ( $. % 10000 ) == 0;
  chomp $_;
  my (undef, undef, undef, $indlit, $occlit, $indnum, $occnum) = 
                                                              split "\t", $_;

  my $pairsfh = select(OUTFILE);

  # Must have a valid mapping (old code must exist in INDXWALK.txt and
  # OCCXWALK2.txt) or we have to drop the record.
  if ( defined $ih{$indnum} && defined $oh{$occnum} ) {
    # DEBUG
    ###print OUTFILE "before: 999\t99\t99\t$indlit\t$occlit\t$indnum\t$occnum\n";
    ###print OUTFILE "after: 999\t99\t99\t$indlit\t$occlit\t$ih{$indnum}\t$oh{$occnum}\n";
    # Assuming the 1st 3 fields are garbage so fill with 9's.
    print OUTFILE "999\t99\t99\t$indlit\t$occlit\t$ih{$indnum}\t$oh{$occnum}\n";
    $convertcnt++;
  } else {
    if ( !defined $ih{$indnum} ) {
      ###print STDOUT "dropping: $indlit\t$occlit\t??$indnum??\t$occnum\n";
    } else {  # $oh{$occnum} is not defined
      ###print STDOUT "dropping: $indlit\t$occlit\t$indnum\t??$occnum??\n";
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

