#!/usr/bin/perl -w
##############################################################################
#     Name: ue9000file.pl
#
#  Summary: Take file slnp41aa.txt and parse into 2 columns.  Code is based on
#           fujifile.pl.  This code is better and works for DMS100/Spectrum or
#           UE9000 files.
#
#  Created: Tue, 01 Aug 2000 14:13:53 (Bob Heckel)
##############################################################################

# Sample input file:

# $ITEM$ 110,5006,124195,172.000,EA,,A0618849,CHC0603X7R104K4B,,
# C3-C65,C67,C69-C71,C74,C93-C95.1,C100,C114-C116,C119,C122,C128,C145,C159-C163,C169,C175-C177,C187,C188,C194-C199,C202,C203,C205,C210-C282
# $ITEM$ 130,5024,136567,104.000,EA,,A0681158,CHC0603X7R103J5B,,
# C75-C92,C96-C99,C101.5-C113,C117,C118,C120,C121,C123-C127,C129-C144,C146-C158,C164-C168,C170-C174,C178-C186,C189-C193,C200,C201,C204,C206-C209

my @wholeline = ();
###my $txtoutput = undef;
###my $filename = '/todel/ue9000/slnp41aa.small.txt';
my $filename = '/todel/ue9000/mxl0402.small.txt';
###my $filename = '/todel/ue9000/junk';
###my $filename = '/todel/ue9000/SLLX0502_MSL_0201.small.txt';

open(FH, "$filename") or die "Can't open $filename: $!";

$/ = '$ITEM$';        # Strange delimiter.

while ( <FH> ) {
  chomp;              # Remove trailing $ITEM$ indicators.
  s/\n//g;            # Remove randomly placed newlines.
  s/\./_/g;           # Per Young Wen, replace periods with underscores.
  @wholeline = split(',', $_);
  # CPC is always in position 6.
  print $wholeline[6];
  # Designation always starts in elements 8 to end of array.
  for ( $i=8; $i<=$#wholeline; $i++ ) {
    print $wholeline[$i];
    # Don't use a comma after the final element.
    unless ( $i == $#wholeline ) {
      print ', ';
    }
  }
  print "\n";
}
