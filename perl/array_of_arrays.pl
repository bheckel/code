#!/usr/bin/perl -w
##############################################################################
#     Name: array_of_arrays.pl
#
#  Summary: Demo of arrays of arrays.
#
#  Adapted: Sun 04 Mar 2001 16:30:33 (Bob Heckel -- p. 271 The Camel 3rd Ed.)
# Modified: Tue 12 Dec 2006 10:42:12 (Bob Heckel)
##############################################################################


# Assign a list of array references to an array.
@AoA = (
         [ "fred", "barney" ],
         [ "george", "jane", "elroy" ],
         [ "homer", "marge", "bart" ],
);
print $AoA[2]->[1];   # prints "marge"
###print $AoA[2][1];   # prints "marge"

# Create an reference to an array of array references.
$refAoA = [
	     [ "fred", "barney" ],
	     [ "george", "jane", "elroy" ],
	     [ "homer", "marge", "bart" ],
];
print $refAoA->[2]->[1];   # prints "marge"
###print $refAoA->[2][1];   # prints "marge"


# Each line of file is an array of words.
while ( <DATA> ) {
  ###@tmp = split;
  ###push(@arr_of_arrs, [ @tmp ]);
  # Better, no new variables used, but more confusing, approach:
  push @arr_of_arrs, [ split ];
  # Would also work:
  ###push @arr_of_arrs, [ somefunction() ];
}

print "Without references:\n";
#                  R    C
print $arr_of_arrs[1]->[2];
# Same
###print $arr_of_arrs[1][2];
print "\n\n";

$refarr_of_arrs = \@arr_of_arrs;
print "Now using array ref:\n";
###print $refarr_of_arrs->[1]->[2];
# Same
print $$refarr_of_arrs[1][2];
print "\n\n";

print "Not what you want:\n";
# ARRAY(0xa05207c)ARRAY(0xa062624)ARRAY(0xa06260c)
print @arr_of_arrs;
print "\n\n";

# Append columns to existing row:
push(@{$arr_of_arrs[1]}, 'wilma', 'betty');
print "All elements in grid:\n";
for $line ( @arr_of_arrs ) {
  print "@$line\n";
}
print "\n";

print "Slice:\n";
@womenslice = ();
###for ( $y=4; $y<6; $y++ ) {
  ###push(@womenslice, $arr_of_arrs[1][$y]);
###}
# Better
@womenslice = @{$arr_of_arrs[1]}[ 4..5 ];
print "@womenslice\n";



#     0     1     2    3
# 0 first  line
# 1 secdon line iZ   middle
# 2 trird  one  here

__DATA__
first line
secdon line iZ middle
trird one here
