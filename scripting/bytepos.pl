#!/usr/bin/perl -w
##############################################################################
#     Name: bytepos
#
#  Summary: Locate NCHS mergefile byte position info.
#
#           TODO key the med risk factors in byte_pos.all.txt
#           TODO wtf won't getopts work?
#
#  Created: Fri 16 Apr 2004 11:08:11 (Bob Heckel)
# Modified: Wed 18 Aug 2004 14:34:48 (Bob Heckel)
##############################################################################
use strict;

my $dat = "$ENV{HOME}/projects/misc/byte_pos.all.txt";

unless ( $ARGV[0] ) {
  die <<EOT;
Usage: $0 SEARCHSTRING
 e.g. $0 birthtime | grep 'NAT/REV'
 e.g. $0 mot.*educ | grep NAT/NON | grep -v fips

 Searches $dat
EOT
}

open FH, "$dat" or die "Error: $0: $!";

while ( <FH> ) {
  s/[\r\n]+$//;
  my ($evt, $var, $byt, $rev, $name) = split /\|/, $_;
  printf("%-3s/%-3s %-30s (%s) %5s\n", $evt, $rev, $name, $var, $byt) if /$ARGV[0]/o;
}
