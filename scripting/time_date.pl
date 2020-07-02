#!/usr/bin/perl -w
##############################################################################
#     Name: time.pl
#
#  Summary: Demo of time manipulation.  Loosely based on ZDNet Torkinson.
#           And Perlmonth #5
#
#  Created: Wed, 08 Sep 1999 09:15:08 (Bob Heckel)
# Modified: Mon, 14 Aug 2000 11:15:50 (Bob Heckel)
##############################################################################

# 20151023
my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime();
my $y = $year+1900;
my $m = $mon+1;
my $dt ="${y}${m}${day}";


###############
# General demos:
$gmt = gmtime();
print "\ngmtime:    $gmt\n";
print "5 hours earlier than here if EST\n";
print "4 hours earlier than here if DST\n";
$loc = localtime();
print "localtime: $loc\n\n";

($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime();
print "Current secs: $sec \n";
print "Current days: $day \n";
print "Current day of week number: $wday \n";
print "Current yr: $year \n\n";

$now = time();
print "current epoch time (secs since Jan 1, 1970): $now\n";
$word = scalar localtime;
print "current scalar time: $word\n\n";

# Drop back to nearest midnight.
###$midnight = $new - ($new % 86400);
###print "rewind to midnight: $midnight or ";
###$midnword = localtime($midnight);
###print $midnword . "\n\n";
###$wordback = scalar localtime($fourdayhence2);
###$backtomidnight = "rewind to midnight $wordback\n";

# 86400 seconds per day.
$fourdayhence = time() + (4 * 86400);
print "epoch 4 days out: $fourdayhence \n";
$fourdaysoutword = scalar localtime $fourdayhence;
print "words 4 days out: $fourdaysoutword\n\n";

# Drop back to nearest midnight.
# Backs up to 20:00 instead of 00:00 b/c gmeantime, see fix below.
$fourdayhence += 43200;
$fourdayhence = $fourdayhence - $fourdayhence % 86400;
print "$fourdayhence or ";
print scalar localtime $fourdayhence;
print "\n\n\n";


####################
# Demo of module #1:
use Time::Local;

$then = time() + 4*86400;
$then = timegm localtime $then;
# local epoch seconds
$then -= $then % 86400;
# truncate to the day
$then = timelocal gmtime $then;      
# back to gmt epoch seconds
print "Fixed:\n";
print scalar localtime $then, "\n\n\n";


####################
# Demo of module #2:
# But the world presents you dates and times as strings. How do you go from a
# string to an epoch seconds value? 
# One way is to write a small custom parser. This has the advantage of being
# flexible and fast:
use Time::Local;
@months{qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)} = (0..11);
# Sample date:
$_ = "19 Dec 1997 15:30:02";

/(\d\d)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)/
     or die "Not a date";
$mday = $1;
$mon  = exists($months{$2}) ? $months{$2} : die "Bad month";
$year = $3 - 1900;
($h, $m, $s) = ($4, $5, $6);
$epoch_seconds = timelocal($s,$m,$h,$mday,$mon,$year);

print $epoch_seconds . "\n";
$proof = scalar localtime $epoch_seconds;
print "Proof: $proof\n\n\n";

########################
# 2038 year bug example.
# 32 - 1 bit for +/- sign = 31.  So there's room for 2147483647.
$maxtime = 2**31-1;
print $maxtime, " or \n";
print scalar(gmtime $maxtime), "\n";
$overloaded = 2**31;
print "Overload: ", $overloaded, " or\n";
$maxtime++;
print $maxtime, "\n";
# Doesn't work, why??
###print scalar(gmtime $maxtime), "\n\n";


########################
# Perlmonth demo.
print "\n";
print "\n";
# print takes its args in list context. Therefore return the array in one big
# chunk, all 9 elements.
print localtime();
print "\n";
print join(" ", localtime() );    # SAME.......>>>>>>>>>>>
print "\n";
print scalar localtime();
print "\n";
# Assignment is scalar context.
$mydate = localtime();
print "\$mydate is: $mydate";
print "\n";

# 6 is 7th element of localtime array. Weekday returned is number 0 - 6.
$x = (localtime())[6];
print "$x\n";
print "\n";

### print "localtime()";  doesnt work.  do this:
@holdlocaltime = localtime();
print @holdlocaltime;
print "\n";
print "\@holdlocaltime is: @holdlocaltime\n";    # SAME.......>>>>>>>>>>>
print "\n";

# Get the current time.
my @curr_time = localtime();
print "\tTime is: $curr_time[2]:$curr_time[1]:$curr_time[0]\n";
# Or simply:
# ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime();
# This only works if no holes.  E.g. $min,$hour,$day,$mon,,,,,,$isdst won't
# work.
($sec, $min, $hr) = localtime();
print "\tTime is: $hr:$min:$sec\n";
# Use this if want non-contiguous datetime pieces:
@americandate = (localtime())[3..5];
printf "%02d-%02d-%02d\n", $americandate[1] +1, $americandate[0], $americandate[2] + 1900;

#%%%%%%%%%%%%%%%%%%
# Daylight savings is in effect:
$dst_yes = (localtime())[8];
