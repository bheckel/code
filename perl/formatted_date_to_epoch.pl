#!/usr/bin/perl -w

use Time::Local;

# Convert time in YYYYMMDDHH24MMSS format tp single number representing
# seconds since epoch as returned by timelocal
#
# Good for converting Oracle dates.
sub numForTime{
  my($timeVal)=@_;

  my($sc,$mi,$hr,$md,$mon,$yr);

  ($yr,$mon,$md,$hr,$mi,$sc)=unpack "a4a2a2a2a2a2a2",$timeVal;

  $mon--;$yr-=1900; # account for month being zero based and year 1900 based

  return timelocal($sc,$mi,$hr,$md,$mon,$yr);
}

print numForTime(20070304013355);
