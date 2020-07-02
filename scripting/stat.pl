#!/usr/bin/perl -w
##############################################################################
#     Name: stat.pl
#
#  Summary: Determine last modified time of files in a dir.  Also see
#           stat_map.pl for file stat usage.
#
#  Created: Mon 06 Aug 2001 12:57:43 (Bob Heckel)
# Modified: Fri 30 Apr 2004 13:29:46 (Bob Heckel)
##############################################################################

# TODO must cd to this dir before running this code
$dir = '/home/bqh0/tmp/testing/';
opendir D, $dir or die "Cannot open $dir: $!\n";

while ( defined ($fileordir = readdir D) ) {
  next if $fileordir =~ /^\.\.?$/;     #skip . and ..
  next if $fileordir !~ /^JUNK/;

  print "$fileordir: ";

  ($mtime) = (stat($fileordir))[9];
  print "mtime UNformatted: $mtime\n";

  $mtime_fmtd = localtime($mtime);

  print "mtime formatted: $mtime_fmtd\n";


  # More terse, don't need an $mtime_fmtd variable:
  ($mtime2) = localtime((stat($fileordir))[9]);
  print "mtime2 formatted: $mtime_fmtd\n";
}

closedir D;
