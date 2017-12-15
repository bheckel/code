#!/usr/bin/perl -w
##############################################################################
#     Name: cookie_location.pl
#
#  Summary: Demo of planting a cookie and sending a user to another site.
#           Call via http://158.111.250.128/bqh0/cgi-bin/cookie_location.pl
#
#  Adapted: Mon 19 May 2003 13:07:30 (Bob Heckel -- Usenet post)
##############################################################################

sub SetCookie {
  $now = time();
  $now = $now+(3600*24)*120;  # 1 hr * 24 * 120 = 120 days in future
  $time = gmtime($now);
  ($wday, $mon, $mday, $t_of_day, $year) = split $time;
  $newtime = "$wday, $mday-$mon-$year $t_of_day GMT";
  $name = uc $p_subject;
  print "Set-Cookie: relocateusr=forwarded2cdcweb; expires=$newtime;\n";
  print "Location: http://www.cdc.gov\n\n";
  
  return 0;
}

SetCookie();
