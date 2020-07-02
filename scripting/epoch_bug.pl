#!/usr/bin/perl -w
##############################################################################
#    Name: epoch_bug.pl
#
# Summary: Demonstration of UNIX "2038 Bug"
#
# Adapted: Tue, 16 Jan 2001 15:53:11 (Bob Heckel -- The Best Of Dates, The
#                                     Worst Of Dates Gilbert Heaton)
##############################################################################

$EndOfTime = 0x7FFFFFFF;        # Last value valid as +signed 32-bit
$Format    = '%04d-%02d-%02d %02d:%02d:%02d' . "\n\n";

@gm = gmtime($EndOfTime);       # Break down last moment
printf("Tick, tick, tick... \t\t $Format", 
                                 $gm[5]+1900, $gm[4]+1, $gm[3], @gm[2,1,0]);

@gm = gmtime($EndOfTime + 1);   # Beyond last valid moment
printf("Kaboom! Happy New Year.\t\t  $Format", 
                                 $gm[5]+1900, $gm[4]+1, $gm[3], @gm[2,1,0]);
