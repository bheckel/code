#!/usr/bin/perl -w
##############################################################################
#     Name: poll_dir_changes.pl
#
#  Summary: Watch, poll, a directory every 60 seconds for changes
#           add / removes.
#
#  Created: Thu 29 Apr 2004 15:51:03 (Bob Heckel)
##############################################################################

###opendir(DIR, "/home/bhb6/data/data1") || die $!;
opendir DIR, "/home/bqh0/tmp" || die $!;
my @old = readdir DIR; # save file names from this directory
closedir DIR || die $!;

while ( sleep 60 ) {
  opendir(DIR2, "/home/bqh0/tmp") || die $!;
  my @new = readdir DIR2;
  closedir DIR2 || die $!;

  if ( @new != @old ) {
    %found = map { $_, 1 } @old;

    foreach $f ( @new ) {
      if ( not $found{$f} ) {
        print "New file:$f\n";
      }
    }
  }
}
