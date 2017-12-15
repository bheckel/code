#!/usr/bin/perl -w
##############################################################################
# Program Name: top20
#
#      Summary: Top 20 largest files on passed directory.
#               Adapted from UnixReview 9/97.
#
#      Adapted: Wed, 25 Aug 1999 12:22:56 (Bob Heckel)
#     Modified: Tue, 07 Sep 1999 20:59:43 (Bob Heckel--allow path to be CWD 
#                                          if not specified)
#     Modified: Sat, 20 May 2000 21:45:56 (Bob Heckel)
##############################################################################

use File::Find;

# TODO fix the thrashing floppy drive.
print "\nMake sure floppy is in drive. Press enter to proceed.\n";
die unless (<STDIN>) eq "\n";

###if ( ! @ARGV ) { @ARGV = '.'};
TODO TODO TODO
# Don't want to search mount points.
if ( ! @ARGV ) { @ARGV = '//c'};

find (sub {
        $size{$File::Find::name} =
          -s if -f;
          ###-s if -f and ($File::Find::name !~ /\/mnt\/floppy/);  # Not working.
      }
      , @ARGV);

@sorted = sort {
  $size{$b} <=> $size{$a}
} keys %size;

splice(@sorted, 20) if @sorted > 20;

foreach ( @sorted ) {
  printf "%10d %s\n", $size{$_}, $_;
}

