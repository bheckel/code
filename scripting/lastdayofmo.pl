#!/usr/bin/perl -w 
# 
# last-day-of-month - check if today is the last day of a month 
# 
# Input: none. 
# Output: none. 
# Exit status: 0 (true) if today is the last day in a month, otherwise 1. 
# Algorithm: Get localtime and advance the day of month by one. Let mktime 
# normalize the result and check whether day of month became 1. 
# Requires: perl5. 
# 

use POSIX; 

@the_time = localtime(time); 
++$the_time[3]; # Element 4 is the day of month [1..31] 
if ( (localtime (POSIX::mktime (@the_time)))[3] == 1 ) { 
  print "it's the last day of the mo.\n";
} else {
  print "it's not the last day of the mo.\n";
}
