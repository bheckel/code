#!/usr/bin/perl
##############################################################################
#     Name: write_unique_lines.pl
#
#  Summary: Write only Ind & Occ unique lines to a new file.
#
#  Created: Mon 12 Aug 2002 17:43:39 (Bob Heckel)
##############################################################################

open FILE, $ARGV[0] || die "$0: can't open file: $!\n";
open NODUP, ">$ARGV[1]" || die "$0: can't open file: $!\n";

while ( <FILE> ) {
  $_ =~ s/[\r\n]+$//;  # chomp
  my ($skip1, $skip2, $skip3, $ind, $occ, $icode, $ocode) = split "\t", $_;

  # Want only unique pairs of I&O.
  $fused = $ind . $occ;

  $seen{lc $fused}++;

  if ( $seen{lc $fused} < 2 ) {
    print NODUP "$skip1\t$skip2\t$skip3\t$ind\t$occ\t$icode\t$ocode\n";
    $numunique++;
  }
}

close NODUP;
close FILE;

print "$numunique unique lines\n";

__END__
Sample input:
084^I12^I15^I3-M COMPANY^ISECRETARY^I189^I570^I^I570^I570^I
096^I99^I15^I3447 S. SADLIER DRIVE^ICLERK CLERK^I999^I586^I
