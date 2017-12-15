#!/usr/bin/perl -w
##############################################################################
#     Name: set_union_difference_operations.pl
#
#  Summary: Determine difference and similarity between arrays
#
#  Created: Thu, 15 Feb 2001 10:19:20 (Bob Heckel)
# Modified: Mon 11 Feb 2013 11:21:02 (Bob Heckel)
##############################################################################

# Adapted from PerlFAQ4.
# E.g. 1 arrays
@array1 = qw(one two three);
@array2 = qw(one     three four);

%count = @union = @intersection = @difference = ();

foreach $element ( @array1, @array2 ) {
  $count{$element}++;
  print "debug: $element $count{$element}\n";
}

foreach $element ( keys %count ) {
  push @union, $element;
  push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element;
}

print "\nunion:        @union\n";
print "intersection: @intersection\n";
print "difference:   @difference\n";



# Adapted from www.perlfaq.com
# E.g. 2 maps
# DESCRIPTION 
# Finding the intersection, difference, or symmetrical difference of two sets
# are elementary set operations. The easiest way to represent sets in Perl is
# by using hashes. Note that we don't need to store if an element is found
# multiple times in the same array. 
# 
# To find the intersection of @cats and @africa, we grep the elements of
# @africa which are in %cats (and hence in @cats). This will give us the
# collection of African cats. To find the cats living outside of Africa, which
# is a set difference, we grep those cats from @cats which are not found in
# %africa. 
# 
# The symmetric difference requires a little more work. We have to combine the
# cats living outside of Africa with the African animals that aren't cats.
# Each of those subsets are set differences, and can be found with the method
# described above. All we need is to combine them in a list.

my @cats   = qw /lion tiger LEOPARD JAGUAR garfield/;
my @africa = qw /elephant JAGUAR hippo baboon lion LEOPARD mamba/;

my %cats   = map {$_ => 1} @cats;
my %africa = map {$_ => 1} @africa;

my @african_cats        = grep { $cats{$_}    } @africa;   # Intersect
my @not_african_cats    = grep { !$africa{$_} } @cats;     # Difference
my @not_africat_animals = ( (grep { !$africa{$_} } @cats), grep { !$cats{$_} } @africa );  # Symmetric difference

print "\n\nunion:                                      @cats, @africa";
print "\n\nintersect (african cats):                   @african_cats";
print "\n\n";
print "difference (non-african cats):                  @not_african_cats";
print "\n\n";
print "symmetric difference (non-african-cat animals): @not_africat_animals";
print "\n\n";

