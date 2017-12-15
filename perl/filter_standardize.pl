#!/usr/bin/perl
##############################################################################
#     Name: filter_standardize.pl (~/zm on rtpsh005)
#
#  Summary: Filter wildly varying batch inspection lot strings
#
#  Created: Fri 16 Oct 2009 13:58:59 (Bob Heckel)
##############################################################################
use warnings;

print "runmacro '/home/chemlms/Scripts/send_result.mcx'\n\n";

open FH, '/var/mail/rsh86800' or die "Error: $0: $!";

while (<FH>) {
  print "$_\n" if /(\dZ[mMpP]\d\d\d\d).*(0?4\d{10,})/;
  print "STANDARDIZED1: $1-$2-01\n" if /(\dZ[mMpP]\d\d\d\d).*(04\d{10,})/;
  print "STANDARDIZED2: $1-0$2-01\n" if /(\dZ[mMpP]\d\d\d\d).*(4\d{10,})/;
  print "STANDARDIZED3 $1-$2-01\n" if /(\dZ[mMpP]\d\d\d\d) - (8\d{10,})/;
}
