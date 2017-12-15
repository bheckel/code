#!/usr/bin/perl -w
##############################################################################
#    Name: sprintf.pl
#
# Summary: Demo of padding with leading zeroes.
#
# Created: Tue 18 Sep 2001 08:50:01 (Bob Heckel)
##############################################################################

for ( $i=1; $i<12; $i++ ) {
  # Format number with 1 leading zero if needed.
  $i = sprintf("%02d", $i);
  print "$i\n";
}
