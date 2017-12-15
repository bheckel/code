#!/usr/bin/perl -w
##############################################################################
#     Name: truth.t
#
#  Summary: Test harness for testing perl (and non-perl) programs.
#
#           To run:
#           $ perl -MTest::Harness -e "runtests 'truth.t'"
#
# Adapted: Wed 05 Dec 2001 12:42:43 (Bob Heckel -- Chromatic www.perl.com)
##############################################################################

print "1..3\n";    # DO NOT FORGET TO UPDATE THIS IF YOU ADD NEW TESTS!

if ( 1 ) {
  print "ok 1\n";
} else {
  print "not ok 1\n";
}

if ( '0 but true' ) {
  print "ok 2\n";
} else {
  print "not ok 2\n";
}

$external_pgm = system("daystil 12 01 2001 12 05");

if ( !$external_pgm ) {
  print "ok 3\n";
} else {
  print "not ok 3\n";
}
