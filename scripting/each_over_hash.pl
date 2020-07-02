#!/usr/bin/perl -w
##############################################################################
# Program Name: each_over_hash.pl 
#
#      Summary: Create a hash and iterate over it.
#
#      Created: Tue, 12 Oct 1999 15:32:59 (Bob Heckel)
#     Modified: Tue 28 Nov 2006 11:10:46 (Bob Heckel)
##############################################################################

# Same.
###%myhash = ("100", "Green", "200", "Orange");
###%myhash = qw(100 Green 200 Orange);
%myhash = qw/100 Green 200 Orange/;

while ( ($key, $value) = each %myhash ) {
  print("$key is $value\n");
}



$h = { one => [ 'a', 'b', 'c' ],
       two => [ 'd', 'e', 'f' ]}; 

print "!!!" . $h->{one}->[0] . "\n";

while ( ($key, $value) = each %$h ) {
  ###print("$key is $value->[0]\n");
  print("$key is @{$value}\n");
}
