#!/usr/bin/perl -w
##############################################################################
#     Name: dotdot.pl
#
#  Summary: Also see perlop.
#
#  Created: Fri 08 Aug 2003 16:21:45 (Bob Heckel)
##############################################################################

foreach $x ( 1 .. 3 ) {
  print "ok $x ";
}
print "\n";

for $x ( 1 .. 3 ) {
  print "ok $x ";
}
print "\n";

for ( 1 .. 3 ) {
  print "ok $_ ";
}
print "\n";
