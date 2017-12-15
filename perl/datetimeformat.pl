#!/usr/bin/perl -w
# assign the returned list elements to scalars for ease of use
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
# or 
###my ($day, $mon, $year, $yday) = (localtime())[3,4,5,7];

my %weekdays = (
    "0" => "Sunday",
    "1" => "Monday",
    "2" => "Tuesday",
    "3" => "Wednesday",
    "4" => "Thursday",
    "5" => "Friday",
    "6" => "Saturday",
);

my %months = (
    "0"  => "January",
    "1"  => "February",
    "2"  => "March",
    "3"  => "April",
    "4"  => "May",
    "5"  => "June",
    "6"  => "July",
    "7"  => "August",
    "8"  => "September",
    "9"  => "October",
    "10" => "November",
    "11" => "December",
);

print "---\n";
print "Date is: $weekdays{$wday}, $months{$mon} $mday, ", 1900 + $year, "\n";
print "---\n";
