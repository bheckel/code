#!/usr/bin/perl -w
##############################################################################
#     Name: examine_apachelog.pl
#
#  Summary: Wade thru an Apache /apache/logs/access_log.  Assumes log is in
#           Common Logfile Format (CLF).
#
# Created: Wed 05 Dec 2001 13:34:44 (Bob Heckel)
##############################################################################

while ( <> ) {
  ($host,$rfc931,$user,$date,$request,$URL,$status,$bytes) =  
              m/^(\S+) (\S+) (\S+) \[([^]]+)\] "(\w+) (\S+).*" (\d+) (\S+)/o;

  print "$host $bytes\n";
}


__END__
Sample /apache/logs/access_log:

47.143.208.108 - - [05/Dec/2001:09:01:00 -0500] "HEAD / HTTP/1.0" 200 0
47.143.208.108 - - [05/Dec/2001:10:01:00 -0500] "HEAD / HTTP/1.0" 200 0
47.143.208.139 - - [05/Dec/2001:10:33:20 -0500] "GET /Webcad/cadfiles HTTP/1.0" 200 1480
47.143.208.139 - - [05/Dec/2001:10:33:20 -0500] "GET /Webcad/cadfiles HTTP/1.0" 200 1480
47.143.208.139 - - [05/Dec/2001:10:33:20 -0500] "GET /Webcad/graphics/cad.gif HTTP/1.0" 304 -
47.143.208.139 - - [05/Dec/2001:10:33:37 -0500] "POST /Webcad/cadfiles HTTP/1.0" 200 2170
47.143.208.139 - - [05/Dec/2001:10:33:46 -0500] "GET /Webcad/data/4k67ac/cad/4k6703_08.cad HTTP/1.0" 200 880420
47.143.208.108 - - [05/Dec/2001:11:01:01 -0500] "HEAD / HTTP/1.0" 200 0
47.143.208.108 - - [05/Dec/2001:12:01:01 -0500] "HEAD / HTTP/1.0" 200 0
47.143.208.108 - - [05/Dec/2001:13:01:00 -0500] "HEAD / HTTP/1.0" 200 0
