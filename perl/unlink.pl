#!/usr/bin/perl -w
##############################################################################
#    Name: unlink.pl
#
# Summary: Delete all files from specified directory.
#
# Created: Fri, 15 Sep 2000 10:54:56 (Bob Heckel)
##############################################################################

$dir = '/home/bheckel/todel/testing/foo';

print "R U Shure? Delete all from $dir?\n";
<STDIN> eq "y\n" ? print "it's your funeral\n" : die "cancelled\n";

opendir FOODIR, $dir || die "Can't open $dir: $!\n";

@files = readdir(FOODIR);

foreach ( @files ) {
  next if /^..?$/;
  print "Deleting $_\n";
  # Damage control.
  sleep(1);
  unlink $dir . '/' . $_;
}
