#!/usr/bin/perl -w
##############################################################################
#     Name: timesheet.cmdline.pl
#
#  Summary: Track hours worked in a week.
#
#  Created: Thu 08 Jun 2006 12:57:17 (Bob Heckel)
##############################################################################

# Read tab delimited input file into an array of arrays.
while ( <DATA> ) {
  chomp;  # the newline at end of each week's hours
  # TODO dump data structure for learning purposes
  push @clockhrs, [split ' '];
}


sub Calc {
  $suntot = $clockhrs[0][1] - $clockhrs[0][0] + $clockhrs[0][3] - 
                                                           $clockhrs[0][2];
  $montot = $clockhrs[1][1] - $clockhrs[1][0] + $clockhrs[1][3] - 
                                                           $clockhrs[1][2];
  $tuetot = $clockhrs[2][1] - $clockhrs[2][0] + $clockhrs[2][3] - 
                                                           $clockhrs[2][2];
  $wedtot = $clockhrs[3][1] - $clockhrs[3][0] + $clockhrs[3][3] - 
                                                           $clockhrs[3][2];
  $thutot = $clockhrs[4][1] - $clockhrs[4][0] + $clockhrs[4][3] - 
                                                           $clockhrs[4][2];
  $fritot = $clockhrs[5][1] - $clockhrs[5][0] + $clockhrs[5][3] - 
                                                           $clockhrs[5][2];
  $sattot = $clockhrs[6][1] - $clockhrs[6][0] + $clockhrs[6][3] - 
                                                           $clockhrs[6][2];
  $grandtot = $suntot + $montot + $tuetot + $wedtot + $thutot + $fritot + $sattot;

  return $grandtot;
}

print "total hours: " . Calc();


# sun
# mon
# ...
# sat
#
# in, lunch out, lunch in, out (in decimal)
__DATA__
0 0 0 0 0
10.75 0 0 18.25
0 0 0 0 0 
0 0 0 0 0 
0 0 0 0 0 
0 0 0 0 0 
0 0 0 0 0 

