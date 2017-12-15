#!/usr/bin/perl -w
##############################################################################
#    Name: change_elems_array.pl
#
# Summary: Array element manipulation, transformation,insertion and assignment.
#
# Created: Tue, 16 Jan 2001 10:52:45 (Bob Heckel)
# Modified: Sun 24 Oct 2004 21:09:27 (Bob Heckel)
##############################################################################

# Create an array with 10 elements.
# Assign values to elements 4 and 7.
@array = (0..10);
@array[4, 7] = ("AA","BB");
print "@array\n\n";


# Create an array with 10 elements and an array with 2 elements.
# Assign values to elements 4 and 7 of the @array1 array.
@array1 = (0..10);
@array2 = ("AA", "BB");
@array1[4, 7] = @array2;
print "@array1\n";

# Eliminate element(s) from array.
@array2 = grep { !/AA/ } @array2;
print "@array2\n"
