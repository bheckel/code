#!/usr/bin/perl -w
##############################################################################
#     Name: floatingpt.pl
#
#  Summary: Determine if two numbers are truly equal, given a specific
#           precision.  Allow for floating point rounding.
#
#  Adapted: Wed, 22 Dec 1999 11:33:22 (Bob Heckel -- from Perl FAQ)
# Modified: Wed 25 Apr 2001 17:30:35 (Bob Heckel)
##############################################################################

# $points refers to _all_ digits in the number.
# In this e.g. 5 is "ok" 6+ is not.
###fp_equal(10.123, 10.1234, 5);

$onethird = 1/3;
print "$onethird\n";
# In this e.g. 3 is "ok" 4+ is not.
# Don't use 0.333
fp_equal($onethird, .333, 3);

sub fp_equal {
  my ($divided, $manual, $points) = @_;

  my ($tX, $tY);
  $tX = sprintf("%.${points}g", $divided);
  $tY = sprintf("%.${points}g", $manual);

  print "tX: $tX\n";
  print "tY: $tY\n";

  if ( $tX eq $tY ) { 
    print "Ok for precision of $points digits.\n";
  } else {
    print "Not equal due to precision.\n";
  }

  return 1;
}

