#!/usr/bin/perl -w
##############################################################################
#     Name: populate_array.pl
#
#  Summary: Read an external file to populate an array.
#
#  Created: Fri 13 Feb 2004 12:35:30 (Bob Heckel)
##############################################################################
use strict;

my @a;

while ( <DATA> ) {
  my ($obs, $fn, $typ, $last, $exp) = split;
  push @a, $fn . "x" . $exp;
}

print "DEBUG: @a\n";


__DATA__
1 BF19.AKX0110.MEDMER1  FILES 12MAR2003 11MAR2004
2 BF19.AKX02013.NATSCP  FILES 03MAR2003 02MAR2004
3 BF19.AKX0204.MEDMER FILEM 28MAR2003 27MAR2004
4 BF19.AKX0205.MICMER FILEM 04MAR2003 03MAR2004
5 BF19.AKX0206.MICCOP FILEM 03MAR2003 02MAR2004
