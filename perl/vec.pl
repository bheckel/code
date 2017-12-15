#!/usr/bin/perl -w
##############################################################################
#     Name: vec.pl
#
#  Summary: Demo of vec().
#
#  Created: Sun 22 Sep 2002 12:32:14 (Bob Heckel)
##############################################################################
use strict;

my $foo = '';
my $bits = undef;

vec($foo, 0, 32) = 0x5065726C;
print "single pl:", $foo, "\n";
print vec($foo, 0, 8), "\n";
# Decimal value of 'e'
print vec($foo, 1, 8), "\n";
# Decimal value of 'r'
print vec($foo, 2, 8), "\n";
print vec($foo, 3, 8), "\n";
vec($foo, 1, 32) = 0x50;
vec($foo, 2, 32) = 0x65726C;
print "double pl:", $foo, "\n";

###vec($bar, 0, 8) = 0x50;
vec($bar, 0, 16) = 0x5065;
$bits = unpack("b*", $bar);
print $bits;
