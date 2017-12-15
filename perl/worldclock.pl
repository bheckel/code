#!/usr/bin/perl

use Clock;

# TODO zero bug when time is e.g. 23:02

my $daylight = (localtime())[8];
print "***Daylight savings time is in effect***\n" if $daylight;

getTime($daylight, '+', 0, 'London');
getTime($daylight, '-', 8, 'San Francisco');
getTime($daylight, '-', 7, 'Denver');
getTime($daylight, '-', 6, 'Chicago');
getTime($daylight, '-', 5, 'New York');
getTime($daylight, '-', 4, 'Halifax');
# TODO how to indicate it's tommorow in Sydney??
getTime($daylight, '+', 9, 'Sydney');      # not sure if they do daylight


sub getTime {
  ($dst, $posneg, $gmtoff, $city) = @_;

  $clock = new Clock;

  ($gmt_adj = $gmtoff - $dst) if $posneg eq '-';
  ($gmt_adj = $gmtoff + $dst) if $posneg eq '+';

  $clock->set_offset($posneg, $gmt_adj, 00, $city);
  $clock->display();
}
