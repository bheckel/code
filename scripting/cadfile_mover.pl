#!/usr/bin/perl -w
##############################################################################
#  Name: cadfile_mover.pl
#
# Summary: Move CAD or nail file to the /gr8xprog tree.  Called by 
#          IWS weblet "GenRad CAD File Uploader"
#
#          Should run setuid to gr8xprog.
#
# Created: Fri 03 Aug 2001 15:11:07 (Bob Heckel)
##############################################################################

# STILL DEBUGGING 

screen($ARGV[0])
          || die "Cannot move $ARGV[0] to /gr8xprog/$ARGV[0].  Exiting.\n";


sub screen {
  my $file_to_move = shift;

  my $retval = 0;

  if ( $file_to_move =~ /(.*\.cad)$/ || $file_to_move =~ /(.*\.nail)$/ ) {
    $untainted = $1;
  } else {
    print "Cannot move $file_to_move (must be CAD or nail file).\n"; 
    return $retval;
  }

  ###$gr8xprogfile = "/home/bheckel/pub/tmp/junk$file_to_move";
  $gr8xprogfile = "/Public/uploadCache/junk$file_to_move";

  $retval = rename $untainted, $gr8xprogfile;

  return $retval;
}
