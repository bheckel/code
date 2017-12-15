#!/perl/bin/perl -w
##############################################################################
# Program Name: local_date_time.pl
#
#      Summary: Convert to English dates based on localtime()
#               Used in nmail.pl
#
#      Created: Thu Feb 18 1999 10:28:14 (Bob Heckel)
# Modified: Mon 10 Jul 2006 13:51:32 (Bob Heckel)
##############################################################################

my ($mon, $day, $year, $today);

my %months = (
   "0"  => "JAN",
   "1"  => "FEB",
   "2"  => "MAR",
   "3"  => "APR",
   "4"  => "MAY",
   "5"  => "JUN",
   "6"  => "JUL",
   "7"  => "AUG",
   "8"  => "SEP",
   "9"  => "OCT",
   "10" => "NOV",
   "11" => "DEC",
);

($mon, $day, $year) = (localtime())[4,3,5];
# Keep Oracle happy by using it's single quoted date format.
$today = "'" . $day . '-' . $months{$mon} . '-' . eval($year+1900) . "'";



# DEPRECATED:

($sec, $min, $hour, $mday, $mon, $year, $wday, $ydat, $isdst) = localtime(time);

# A BLOCK by itself (labeled or not) is semantically equivalent to a loop that
# executes once.  Used here as a Select Case statement.

LONGWKDAY: {
        $longwdaystr = Sunday, last LONGWKDAY  if $wday == 0;
        $longwdaystr = Monday, last LONGWKDAY  if $wday == 1;
        $longwdaystr = Tuesday, last LONGWKDAY  if $wday == 2;
        $longwdaystr = Wednesday, last LONGWKDAY  if $wday == 3;
        $longwdaystr = Thursday, last LONGWKDAY  if $wday == 4;
        $longwdaystr = Friday, last LONGWKDAY  if $wday == 5;
        $longwdaystr = Saturday, last LONGWKDAY  if $wday == 6;
        $nothing = 1;
   }
###print "$wday now $longwdaystr\n";  #DEBUG


SHORTWKDAY: {
        $shortwdaystr = Sun, last SHORTWKDAY  if $wday == 0;
        $shortwdaystr = Mon, last SHORTWKDAY  if $wday == 1;
        $shortwdaystr = Tue, last SHORTWKDAY  if $wday == 2;
        $shortwdaystr = Wed, last SHORTWKDAY  if $wday == 3;
        $shortwdaystr = Thu, last SHORTWKDAY  if $wday == 4;
        $shortwdaystr = Fri, last SHORTWKDAY  if $wday == 5;
        $shortwdaystr = Sat, last SHORTWKDAY  if $wday == 6;
        $nothing = 1;
   }
###print "$wday now $shortwdaystr\n";  #DEBUG


LMONTH: {
        $longmonstr = January, last LMONTH  if $mon == 0;
        $longmonstr = February, last LMONTH  if $mon == 1;
        $longmonstr = March, last LMONTH  if $mon == 2;
        $longmonstr = April, last LMONTH  if $mon == 3;
        $longmonstr = May, last LMONTH  if $mon == 4;
        $longmonstr = June, last LMONTH  if $mon == 5;
        $longmonstr = July, last LMONTH  if $mon == 6;
        $longmonstr = August, last LMONTH  if $mon == 7;
        $longmonstr = September, last LMONTH  if $mon == 8;
        $longmonstr = October, last LMONTH  if $mon == 9;
        $longmonstr = November, last LMONTH  if $mon == 10;
        $longmonstr = December, last LMONTH  if $mon == 11;
        $nothing = 1;
   }
###print "$mon now $longmonstr\n";  #DEBUG


SMONTH: {
        $shortmonstr = Jan, last SMONTH  if $mon == 0;
        $shortmonstr = Feb, last SMONTH  if $mon == 1;
        $shortmonstr = Mar, last SMONTH  if $mon == 2;
        $shortmonstr = Apr, last SMONTH  if $mon == 3;
        $shortmonstr = May, last SMONTH  if $mon == 4;
        $shortmonstr = Jun, last SMONTH  if $mon == 5;
        $shortmonstr = Jul, last SMONTH  if $mon == 6;
        $shortmonstr = Aug, last SMONTH  if $mon == 7;
        $shortmonstr = Sep, last SMONTH  if $mon == 8;
        $shortmonstr = Oct, last SMONTH  if $mon == 9;
        $shortmonstr = Nov, last SMONTH  if $mon == 10;
        $shortmonstr = Dec, last SMONTH  if $mon == 11;
        $nothing = 1;
   }
###print "$mon now $shortmonstr\n";  #DEBUG


 YEAR: {
        $yearstr = 1999, last YEAR  if $year == 99;
        $yearstr = 2000, last YEAR  if $year == 100;
        $yearstr = 2001, last YEAR  if $year == 101;
        $yearstr = 2002, last YEAR  if $year == 102;
        $yearstr = 2003, last YEAR  if $year == 103;
        $yearstr = 2004, last YEAR  if $year == 104;
        $yearstr = 2005, last YEAR  if $year == 105;
        $nothing = 1;
   }
###print "$year now $yearstr\n";  #DEBUG


# Min & sec don't have leading zeros.
$min = 0 . $min if $min < 10;
$sec = 0 . $sec if $sec < 10;

# Daylight savings.
if ($isdst == 0) {
   $isdst = "EST"
   } else {
   $isdst = "EDT"
   }


# E.g. Thu Feb 18 1999 10:58:26 -0500 EST is
print "$wdaystr $shortmonstr $mday $yearstr $hour:$min:$sec -0500 $isdst\n";
