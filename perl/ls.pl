#!/usr/bin/perl -w
##############################################################################
#    Name: ls.pl
#
# Summary: Poor man's ls.
#
# Created: Created: Sat, 25 Dec 1999 17:09:20 (Bob Heckel)
##############################################################################

if ( defined($x = $ARGV[0]) ) {
  print system("ls $x");
}

