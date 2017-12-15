#!/usr/bin/perl -w

# Created: Thu Apr 22 09:34:59 2004 (Bob Heckel)
# Useractive Objective:

# The splice function is used to remove and/or add elements to an array.
# splice(@array,offset,length,list);
#
# This works a lot like how substr works with strings except that the extracted
# elements are actually removed and replaced by a list (if a list is given).
#
# Imagine we have one array (@array1) with 10 elements. How could you splice

# @array2 into the middle of @array1 without removing any elements of @array1?

@array1 = (1,2,3,4,5,6,7,8,9,10,11);
@array2 = qq(A B C);

splice @array1, $#array1/2, 0, @array2;
print "@array1";
