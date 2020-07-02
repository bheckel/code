#!/usr/bin/perl -w
##############################################################################
#     Name: modify_grid.pl
#
#  Summary: Demo of opening, reading, modifying and saving a textfile using
#           an array of arrays.  Anonymous arrays.
#
#  Created: Wed 17 Jul 2002 09:06:21 (Bob Heckel)
# Modified: Mon 29 Oct 2007 14:40:19 (Bob Heckel)
##############################################################################
use strict;

# Tab-delimited input file.
###open FILE, "timesheet.dat" || die "$0: can't open file: $!\n";
my @AoA = ();
###while ( <FILE> ) {
while ( <DATA> ) {
  chomp;  # newline at end of each week's hours
  push @AoA, [ split '\t' ];   # create an array of arrays
}

print "Here is the read-in array of arrays (list of lists):\n";
for my $aref ( @AoA ) {
  print "@$aref\n";
}
print "\n";

# Visual confirmation.
for my $i ( 0 .. $#AoA ) {
  my $aref = $AoA[$i];
  my $n = @$aref - 1;
  for my $j ( 0 .. $n ) {
    print "element $i $j is x$AoA[$i][$j]x\n";
  }
}
print "\n";

# Easily edit any number like this.
$AoA[0][1] = 42;

###open FILE2, ">timesheet.dat2" || die "$0: can't open file: $!\n";
# Write changes.
for my $i ( 0 .. $#AoA ) {
  my $aref = $AoA[$i];
  my $n = @$aref - 1;
  for my $j ( 0 .. $n ) {
    ###print FILE2 "$AoA[$i][$j]\t";
    print "$AoA[$i][$j]\t";
  }
  ###print FILE2 "\n";  # replace the newline between weeks (chomped earlier)
  print "\n";  # replace the newline between weeks (chomped earlier)
}
###close FILE2;
#

__DATA__
8	11	12	16	9	12
6	11	10	16	9	5
