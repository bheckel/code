#!/usr/bin/perl
##############################################################################
#     Name: recursion_search_array.pl
#
#  Summary: Demo of efficiently halving an array to speed up searching
#
#  Adapted: Mon 04 Apr 2011 14:02:57 (Bob Heckel -- Modern Perl chromatic)
##############################################################################
use strict;
use warnings;
use Carp 'cluck';

my @elements = (1,5,6,19,48,77,997,1025,7777,8192,9999);

###array_elem_exists(1, @elements) && print "found first element in array\n";
###!array_elem_exists(10000, @elements) && print "did not find element in array\n";
array_elem_exists(19, @elements) && print "found element in array\n";

sub array_elem_exists {
  my ($item,@array) = @_;

  # Every new invocation of this fn creates its own instance of a lexical
  # scope.  See:
  cluck "[$item] (@array)";

  # break recursion if there are no elements to search
  return unless @array;

  # biasdown, if there are an odd number of elements
  my $midpoint = int((@array/2)-0.5);
  my $miditem = $array[$midpoint];

  # return true if the current element is the target
  return 1 if $item==$miditem;

  # return false if the current element is the only element
  return if @array==1;

  # split the array down and recurse
  return array_elem_exists($item,@array[0..$midpoint]) if $item < $miditem;

  # split the array up and recurse
  return array_elem_exists($item,@array[$midpoint+1..$#array]);
}
