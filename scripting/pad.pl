#!/usr/bin/perl -w
##############################################################################
#     Name: pad.pl
#
#  Summary: Place data in specific columns, padding to a length of 97.
#
#  Created: Thu 12 Sep 2002 12:56:36 (Bob Heckel)
##############################################################################
use strict;

###open FILE, "dorothy.txt" or die "Error: $0: $!";
###while ( my $line = <FILE> ) { 
while ( my $line = <DATA> ) { 
  $line =~ s/[\r\n]+$//;
  my ($num, $ilit, $olit) = split '\t', $line;
  # Zero pad the number and left align the strings.
  printf "%.6d %-34s %-55s\n", $num, $ilit, $olit;
}
###close FILE;

__DATA__
25	AMES & WEBB	CONSTRUCTION
50	SELF-EMPLOYED	ELECTRICIAN/MASTER MECHANIC
75	FURNITURE MANUFACTURING	FOREMAN 
