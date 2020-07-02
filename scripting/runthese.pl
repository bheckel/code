#!/usr/bin/perl -w
##############################################################################
#     Name: runthese.pl
#
#  Summary: Run a series of programs (or files e.g. spreadsheets) via
#           START.EXE, waiting until one is finished before running the next.
#           Original motivation was to get around the disaster that is the BAT
#           file FOR loop.
#
#           Windows only!!  Must use ActiveState's Perl (perla).
#           For tbe2's project, assuming we compiled this via:
#           $ perl2exe runthese.pl
#           Then cd to the dir and run it from cmd, not Cygwin.
#
#  Created: Tue 12 Nov 2002 14:10:54 (Bob Heckel)
# Modified: Wed 13 Nov 2002 08:59:16 (Bob Heckel) 
##############################################################################
#
$|++;  # show 'ok' status as pgm runs

if ( !@ARGV || $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0 FILE1 FILE2...\nRuns file one after the other ";
  print STDERR "using Window's START.EXE.\n";
  exit(__LINE__);
}

print "Running @ARGV.\n";

foreach ( @ARGV ) {
  if ( system("start /WAIT $_") ) {
    print "Warning: problem running START on $_\n";
  } else {
    print "ok $_\n";
  }
}

print "Finished.\n";
print "Press enter to close this window.\n";
<STDIN>;

exit 0;
