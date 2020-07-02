#!/usr/bin/perl -w
##############################################################################
#    Name: or.pl
#
# Summary: Default values.  Caution: won't work if $x == 0.
#
# Created: Thu 12 Apr 2001 09:44:12 (Bob Heckel)
##############################################################################

$default = 'none';
# Toggle this to demonstrate pgm.
$x = 'a value';

# Same.
print $x ? $x : $default;
print "\n";
# Same.
print $x ||= $default;
