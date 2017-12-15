#!/usr/bin/perl
##############################################################################
#     Name: multidimension_array_dynamic.pl
#
#  Summary: Demo of multi-dimensional arrays built dynamically plus insertion
#           of rows and columns.
#
#  Created: Wed 13 Dec 2006 13:42:10 (Bob Heckel)
##############################################################################
use strict;
use warnings;
use Data::Dumper; 

# Assign a predefined list of array references to an array.
my @AoA = (
	    [ "fred", "barney" ],
	    [ "george", "jane", "elroy" ],
	    [ "homer", "marge", "bart" ],
);
print $AoA[2][1];   # prints "marge"


# Assign a dynamic list of array references to an array.
my @AoA2 = ();
while ( <DATA> ) {
  my @tmp = split;
  # Add new row
  push @AoA2, [ @tmp ];
}
print $AoA2[2][1];   # prints "marge"

print "before\n";
print Dumper @AoA2;

# Add new columns 3 thru 5
###for my $x ( 0..2 ) {
for my $x ( 0..$#AoA2 ) {
  ###for my $y ( 3..5 ) {
  for my $y ( $#AoA2+1..$#AoA2+3 ) {
    $AoA2[$x][$y] = "column " . $y;
  }
}

print "after\n";
print Dumper @AoA2;



__DATA__
fred barney 
george jane elroy 
homer marge bart 
