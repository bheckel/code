#!/usr/bin/perl -w
##############################################################################
#     Name: bubble-sort.pl
#
#  Summary: Use the very slow (unless already mostly sorted) bubble sort 
#           approach to sorting.
#
#  Adapted: Mon 30 Sep 2002 16:29:51 (Bob Heckel--Mastering Algorithms)
# Modified: Sun 18 Apr 2004 11:35:44 (Bob Heckel)
##############################################################################
use strict;

###my @array = qw(able was i ere i saw elba);
my @array = qw(8 5 9 3 2 5 6 1);
print "unsorted @array\n";

###############
# W/o references and subs:
@array = (5,3,2,1,4);

for ( my $i=$#array; $i; $i-- ) {
  for ( my $j=1; $j<=$i; $j++ ) {
    if ( $array[$j-1] gt $array[$j] ) {
      # Swap
      my $tmp = $array[$j-1];
      $array[$j-1] = $array[$j];
      $array[$j] = $tmp;
    }
  }
}

foreach my $elem ( @array ){
    print "$elem";
}
###############


###############
# With references and subs:
bubblesort(\@array);
print "sorted @array\n";


sub bubblesort {
  my $rarray = shift;

  my $i;              # initial index for the bubbling scan
  my $j;              # running index for the bubbling scan
  my $ncomp = 0;      # number of comparisons
  my $nswap = 0;      # number of swaps

  for ( $i=$#$rarray; $i; $i-- ) {
    for ( $j=1; $j<=$i; $j++ ) {
      $ncomp++;
      # Swap if needed.
      if ( $rarray->[$j-1] gt $rarray->[$j] ) {
        @$rarray[$j, $j-1] = @$rarray[$j-1, $j];
        $nswap++;
      }
    }
  }
  print "bubblesort:  ", scalar @$rarray, " elements, $ncomp comparisons, "; 
  print $nswap, " swaps\n";
}
###############
