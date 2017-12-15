#!/usr/bin/perl -w
##############################################################################
#    Name: lock.pl
#
# Summary: Using closures to share state.
#
# Adapted: Wed 11 Apr 2001 13:00:33 (Bob Heckel -- p. 58 OO Perl - Conway)
##############################################################################

{
  # Access to this lexical is still available to lock() and unlock() after
  # this block is exited.
  my $locked;

  sub lock { return 0 if $locked; $locked = 1; }
  sub unlock { $locked = 0; }
}

lock() or print "1 Sorry, resource already in use.\n";
print "...doing things to the locked item...\n";
# Try to get at it while it's locked.
lock() or print "2 Sorry, resource already in use.\n";
unlock();
# OK this time.
lock() or print "3 Sorry, resource already in use.\n";
