#!/usr/bin/perl -w
##############################################################################
#     Name: tab_delimited.pl
#
#  Summary: Demo of harvesting extracting data from a tab-delimited file and
#           converting the field data.
#
#  Created: Thu 24 Apr 2003 15:58:47 (Bob Heckel)
# Modified: Sat 24 May 2003 18:58:28 (Bob Heckel)
##############################################################################

open OUTFH, ">junk.dat" or die "Error: $0: $!";

while ( <DATA> ) {
  chomp $_;
  my ($i, $j, $k, $l, $m, $n) = split '\t';
  warn "$_\n" if !$i or !$j or !$k or !$l or !$m or !$n;
  # Remove time info.
  $k =~ s/ .*/'/g;
  print OUTFH "$i\t$j\t$k\t$l\t$m\t$n\n";
}

__DATA__
8	1	'9/2/1994'	1.84	15.65	1
9	1	'9/2/1994'	5.78	15.65	1
223	4	'2/25/1998 17:51'	0	48.38	7
10	1	'12/16/1994'	1.88	14.81	1
