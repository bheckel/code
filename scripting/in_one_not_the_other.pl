#!/usr/bin/perl
##############################################################################
#     Name: in_one_not_the_other.pl
#
#  Summary: Check to see if all data in one file is in the other.
#
#           Only works to see if everything in CONTROL is in CHECK, i.e. it's 
#           a left join.  Missings on CHECK are ignored.
#
#           See compare_symmetric_difference.pl for a more complex version or
#           see set_union_difference_operations.pl for tutorial style
#
#  Created: Mon 11 Feb 2013 09:58:00 (Bob Heckel)
# Modified: Tue 30 Aug 2016 10:45:07 (Bob Heckel)
##############################################################################
use warnings;

open CONTROL, '/Drugs/Personnel/bob/tmp/1' or die "$!";
# We're expecting all that is in CONTROL is in CHECK
open CHECK, '/Drugs/Personnel/bob/tmp/2' or die "$!";

@control = <CONTROL>;
@check = <CHECK>;

%known = map { $_, 1 } @control;

$n = 0;
foreach $item ( @check ) {
  if ( not $known{$item} ) {   
    print $item;
    $n++;
  }
}

print "\n$n differences in CHECK that are not in CONTROL.\n";
print "\nthere may be missing data in CONTROL that *is* in CHECK.\n";
