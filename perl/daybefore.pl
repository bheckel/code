#!/usr/bin/perl
##############################################################################
#     Name: daybefore.pl
#
#  Summary: Calculate the day before 20050801
#
#  Adapted: Sat 10 Sep 2005 09:40:39 (Bob Heckel -- www.unixreview.com)
##############################################################################
use strict;
use warnings;
use Time::Local;

my $a=timelocal(0,0,12,01,07,105);
my ($mday, $mon, $year) = (localtime($a-86400))[3,4,5];
$mon++;
$year += 1900;
printf("%04d%02d%02d\n", $year, $mon, $mday);
