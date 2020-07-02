#!/usr/bin/perl -w
##############################################################################
#    Name: leap
#
# Summary: Determine if year passed to this pgm is a leap year.
#
# Created: Mon 26 Feb 2001 12:14:07 (Bob Heckel)
##############################################################################

if ( $#ARGV ) {
  print "Usage: $0 year\n";
  exit(-1);
}

###$year = 1800;    # no
###$year = 2000;    # yes
$year = $ARGV[0];

if ( (!($year % 4) && ($year % 100)) || !($year % 400) ) {
  print "$year is a leap year.\n";
} else {
  print "$year is not a leap year.\n";
}


