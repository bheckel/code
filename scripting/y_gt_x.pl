#!/usr/bin/perl

# Select elements from a 2-D array where y > x
# Adapted: Tue 13 Mar 2001 17:08:31 (Bob Heckel --
#                       http://www.raycosoft.com/rayco/support/perl_tutor.html)

# An array of references to anonymous arrays
@data_points = ( [ 5, 12 ], [ 20, -3 ], [ 2, 2 ], [ 13, 20 ] );

@y_gt_x = grep { $_->[1] > $_->[0] } @data_points;

#       ___ is an ARRAY reference
foreach $xy ( @y_gt_x ) { print "$xy->[0], $xy->[1]\n" }
