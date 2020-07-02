#!/usr/bin/perl
##############################################################################
#     Name: multidimension_array.pl
#
#  Summary: Demo of multi-dimensional arrays.
#
#  Created: Wed 13 Dec 2006 13:42:10 (Bob Heckel)
##############################################################################
use strict;
use warnings;

######## using arrays ##########
# Assign a list of array references to an array.
my @AoA = (
	    [ "fred", "barney" ],
	    [ "george", "jane", "elroy" ],
	    [ "homer", "marge", "bart" ],
);
###print "@AoA";
print $AoA[2][1];   # prints "marge"
###use Data::Dumper; print Dumper @AoA;

my @cube = (
	    [ [ "fred", "barney"          ], [ "main",   "sidekick"       ] ],
	    [ [ "george", "jane", "elroy" ], [ "father", "mother", "son"  ] ],
	    [ [ "homer", "marge", "bart"  ], [ "doah",   "hair",   "uhoh" ] ],
);

###use Data::Dumper; print Dumper @cube;
print $cube[2][1][0];   # prints "doah"
print $cube[2][1][-3];   # prints "doah"



######## using refs ##########
my $r = [
	  [ "fred", "barney" ],
	  [ "george", "jane", "elroy" ],
	  [ "homer", "marge", "bart" ],
];
print $r->[2][1];  # prints "marge"
###print Dumper $r;
