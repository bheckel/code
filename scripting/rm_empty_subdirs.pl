#!/usr/bin/perl -w
##############################################################################
# Program Name: /home/bqh0/bin/rmsubdir
#
#      Summary: Adapted from 9/97 UnixReview.  Removes all empty
#               subdirectories based on the fully qualified path passed to it. 
#               Usage: smash /topleveldirwithsubdirstowipeifempty
#
#      Created: Wed, 25 Aug 1999 10:52:30 (Bob Heckel)
# Modified: Tue 24 Jun 2003 12:22:29 (Bob Heckel)
##############################################################################
use File::Find;

my $msg = "Usage: rmsubdir topleveldir1 [topleveldir2...]\n" .
          "Removes empty subdirectories under (but not including) topleveldir1... \n";

# At least 2 params must be passed.
die "$msg" if $#ARGV < 0;

finddepth(sub { rmdir $_; }, @ARGV);


# Traditional method that does the same thing:
###    &smash(@ARGV);
###    sub smash {
###      my $dir = shift;
###      opendir DIR, $dir or return;
###      my @contents =
###        map "$dir/$_",
###        sort grep !/^\.\.?$/,
###        readdir DIR;
###      closedir DIR;
###      foreach (@contents) {
###        next unless !-l && -d;
###        &smash($_);
###        rmdir $_;
###      }
###    }
