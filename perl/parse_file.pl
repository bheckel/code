#!/usr/bin/perl -w
##############################################################################
#     Name: parse_file.pl
#
#  Summary: Gather 3 different times from a .tim file
#
#  Created: Tue 15 May 2001 14:10:47 (Bob Heckel)
##############################################################################
###use strict;

my %hoh= ();

foreach $metric ('Total Cycle Time', 'Fiducial Time', 'Placements') {
  my ($b, $m, $t) = parseFile($metric, 'CP6B.tim');
  # Side effect is to make unique hash keys.  Without it, only get the final
  # iteration's data (see below to avoid this).
  $m = "$metric: $m";
  # Data structure requires hash of hashes (see below for hohoh).
  $hoh{$b}{$m} = $t;

}

# Display.
for my $bdname ( keys %hoh ) {
  print $bdname, " \n";
  for my $machname ( sort keys %{$hoh{$bdname}} ) {
    print "$machname=$hoh{$bdname}{$machname}\n";
  }
}


# Gather desired pieces of data from file.
sub parseFile {
  my $type = shift;
  my $file = shift;

  my $board = undef;
  my $mach  = undef;
  my $time  = undef;

  open(FILE, $file) || die "Error in parseFile(): Can't open $file: $!\n";

  while ( <FILE> ) {
    if ( m/Board Name:\s+\b(\w+)\b/ ) {
      $board = $1;
    }
    if ( m/Machine Name:\s+\b(\w+)\b/ ) {
      $mach = $1;
    }
    #                                 floating point number
    #                -----------------------------------------------
    if ( m/${type}: +([+-]?(\d+\.\d+|\d+\.|\.\d+|\d+)([eE][+-]?\d+)?)/ ) {
      $time = $1;
    }
  }
  close(FILE);

  return $board, $mach, $time;
}

##############################################################################
 ############################################################################ 
# Or use a hash of hash of hashes to avoid the messy unique key thing:
# TODO this may not work...

###my %hohoh= ();
###
###foreach $metric ('Total Cycle Time', 'Fiducial Time', 'Placements') {
###  my ($b, $m, $t) = parseFile($metric, 'CP6B.tim');
###  # Side effect is to make unique hash keys.
###  ###$m = "$metric: $m";
###  # Data structure requires hash of hash hashes.
###  $hohoh{$b}{$m}{$metric} = $t;
###
###}
###
#### Display.
###for my $bdname ( keys %hoh ) {
###  print $bdname, " \n";
###  for my $machname ( sort keys %{$hohoh{$bdname}} ) {
###    print "$machname=$hohoh{$bdname}{$machname}{'Placements'}\n";
###  }
###}
 ############################################################################ 
##############################################################################


__END__
partial CP6B.tim

************** FujiCam Cycle Time Report ***************

	Machine Name:       CP6B
	Board Name:         NT4K67AC0625
	Board Revision:     0603
	Board Description:  copy from line 5 ,02/02/01
	Created By:         Qui Ngo
	Creation Time/Date: 16:35:34, 02-07-2001

********************************************************

	Panel Load Time:                 4.00
	Fiducial Time:                   1.28
	Placement Time:                  68.22
	Total Cycle Time:                73.50
	Number of Placements:            520
	Average Placement Time Per Part: 0.14

****************** CP642 Timing Report *****************

              PickUp           Place  Time    Total
part:             F1                  0.09     0.09 
part:            R15                  0.11     0.20 
part:            R28                  0.09     0.29 
part:             F2                  0.11     0.40 
part:            R14                  0.11     0.51 
part:            C41                  0.11     0.62 
part:            C53                  0.11     0.73 
part:            C57                  0.09     0.82 
part:            R41                  0.14     0.96 
...snip...
part:            C52                  0.11     1.08 
Panel Load Time                       4.00     4.00
Fiducial Time                         1.28     5.28
part:            C60              F1  0.11     5.39 
part:            C59             R15  0.09     5.48 
part:            C55             R28  0.11     5.59 
part:            Q13             R41  0.23     6.38 
part:                            R62  0.13    73.50 
