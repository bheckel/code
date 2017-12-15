#!/usr/bin/perl -w
##############################################################################
#     Name: flush.pl
#
#  Summary: Demo of the necessity of flushing buffers.
#
#  Created: Sun, 03 Sep 2000 21:11:51 (Bob Heckel)
##############################################################################

$| = 1;
$x = 5;

for ($i=1; $i<20; $i++) {
  $pct = ($x / $i) * 100;
  printf("%3d%% complete", $pct);
  sleep(1);
  print "\b" x 13;
}
