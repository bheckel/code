#!/usr/bin/perl -w
##############################################################################
#    Name: autoload_short.pl
#
# Summary: AUTOLOAD (a catchall subroutine) demo.
#
# Created: Wed 11 Apr 2001 13:00:33 (Bob Heckel)
##############################################################################

nosuchsubroutine('Hal');

sub AUTOLOAD {
  print "I'm sorry $_[0], I can't do that.\n";
  print "$AUTOLOAD doesn't exist\n";
}
