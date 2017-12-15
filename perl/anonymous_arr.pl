#!/usr/bin/perl -w
##############################################################################
#     Name: anonymous_arr.pl
#
#  Summary: Demo of using anonymous arrays.
#
#  Created: Thu 07 Aug 2003 15:49:19 (Bob Heckel)
# Modified: Tue 06 Mar 2007 12:40:25 (Bob Heckel)
##############################################################################

# This...
$aref1 = [ 1, 2, 3 ];

# ...does the same as this but without a superfluous array:
@array = (1, 2, 3);
$aref2 = \@array;

print "@$aref1 same as @$aref2\n";
# More readable
print "@{ $aref1 } same as @{ $aref2 }\n";



# You can wrap things that return lists in [ ] and create arrayrefs:
$data = 'foo, bar,baz, boom';
# This removes the trailing spaces while splitting on comma:
$data = [ split /\s*,\s*/, $data ];
print $$data[1];
print ${ $data }[1];
print ${ $data }[3];
