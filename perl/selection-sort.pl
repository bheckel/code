#!/usr/bin/perl -w
##############################################################################
#     Name: selection-sort.pl
#
#  Summary: Use the very slow selection sort approach to sorting.
#
#  Adapted: Mon 30 Sep 2002 16:29:51 (Bob Heckel--Mastering Algorithms)
##############################################################################
use strict;

###@array = qw(able was i ere i saw elba);
@array = qw(8 5 9 3 2 5 6 1);
selection_sort(\@array);
print "@array";

sub selection_sort {
  my $arr_ref = shift;

  my $i;   # starting index of a minimum-finding scan
  my $j;   # running index of a minimum-finding scan

  #                7 is max array elem subscript in this e.g.
  for ( $i=0; $i<$#$arr_ref; $i++ ) {
    my $min_idx = $i;                # index of the minimum element
    my $min_val = $arr_ref->[$min_idx];  # minimum value

    for ( $j=$i+1; $j<@$arr_ref; $j++ ) {
        # Update minimum if necessary.
        ($min_idx, $min_val) = ($j, $arr_ref->[$j]) 
                                              if $arr_ref->[$j] lt $min_val;
    }

    # Swap if needed using a slice.
    @$arr_ref[$min_idx, $i] = @$arr_ref[$i, $min_idx] unless $min_idx == $i;
  }
}
