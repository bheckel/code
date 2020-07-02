#!/usr/bin/perl -w

reformatDate('994436212');

# Have unixtime, want 20010707.
sub reformatDate {
  $the_time = shift;
  ($yr, $mo, $day) = (localtime($the_time))[5,4,3];
  $yr += 1900;
  $mo = sprintf("%02d", $mo);
  $day = sprintf("%02d", $day);
  print "$yr$mo$day\n";
}
