#!/usr/bin/perl -w
##############################################################################
#     Name: default_val.pl
#
#  Summary: Provide a default value for uninitialized values using the
#           ternary hook (a.k.a. conditional) operator.
#
#  Created: Sat 28 Jun 2003 08:54:14 (Bob Heckel)
# Modified: Tue 31 Aug 2004 12:38:12 (Bob Heckel)
##############################################################################

###$x = 3;

# If $x doesn't have a value, give it 42, otherwise use it's value.
$x = ($x ? $x : 42);
print "$x\n";

###$ARGV[0] = ($ARGV[0] ? $ARGV[0] : 66);
###print "$ARGV[0]\n";

# Better
$ARGV[0] ||= 66;
print "$ARGV[0]\n";
