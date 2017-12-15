#!/usr/bin/perl -w
##############################################################################
#    Name: fujifiducial.pl
#
# Summary: Parse fuji fiducial input file.  See sample at bottom.
#
# Created: Mon, 14 Aug 2000 17:26:21 (Bob Heckel)
##############################################################################

Extract();


sub Extract {
  open(FH, "/home/bheckel/fid.dat") || die "$0--Can't open file: $!\n";
  ###print "Fid Name\tX Loc\tY Loc\tSide\tSize\n";     # Header.
  printf("%-14s %10s %9s %9s %9s\n", 'Fid Name', 'X Loc', 'Y Loc',
                                        'Side', 'Size');
  # Intialize new datablock...
  $fline = undef;
  $itemname_odd = undef;
  $itemname_even = undef;
  while ( <FH> ) {
    next if /^$/;
    # New entry.
    if ( /^Number of\s+(\w+)\s+Fiducials on (\w)\w+ Side \= +(\d+)/i ) {
      $odd = -1 if $3 != $placehold3;
      $even = 0 if $3 != $placehold3;
      $placehold3 = $3;
      # Finish up previous datablock.
      if ( $fline ) {
        print "$fline";
        $fline = undef;
      }
      if ( $2 eq 'T' ) {
        $odd += 2;
        $itemname_odd = "$2FID$odd ";
        $itemname_even = undef;
      } else {     # Assume 'B'
        $even += 2;
        $itemname_even = "$2FID$even ";
        $itemname_odd = undef;
      }
    }
    # Continued entry.
    if ( /Fiducial diameter = r(\d+) at x=(-?\d+\.?\d+)\s+y=(-?\d+\.?\d+)/ ) {
      if ( $itemname_odd ) {
        ###$fline .= "$itemname_odd\t$2\t$3\t$odd\t$1\n"; 
        $fline .= sprintf("%-14s %10.3f %9.3f %9d %9d\n", $itemname_odd, $2, $3, $odd, $1); 
      } else {
        ###$fline .= "$itemname_even\t$2\t$3\t$even\t$1\n"; 
        $fline .= sprintf("%-14s %10.3f %9.3f %9d %9d\n", $itemname_even, $2, $3, $even, $1); 
      }
    }
  }
  print "\n";
  close(FH);
}

# Sample input:
# Fiducial diameter = r61 at x=-0.295  y=11.457 
# Fiducial diameter = r62 at x=-11.614 y=11.457 
# Fiducial diameter = r63 at x=-11.693 y=0.079 
# Fiducial diameter = r64 at x=-0.295  y=0.039 
# 
# Number of Global Fiducials on Bottom Side = 4
# 
# Fiducial diameter = r65 at x=-0.295  y=11.457 
# Fiducial diameter = r66 at x=-11.614 y=11.457 
# Fiducial diameter = r67 at x=-11.693 y=0.079 
# Fiducial diameter = r68 at x=-0.295  y=0.039 
# 
# Sample output:

# Fid Name        X Loc   Y Loc   Side    Size
# TFID1   -0.295  11.457  1       61
# TFID1   -11.614 11.457  1       62
# TFID1   -11.693 0.079   1       63
# TFID1   -0.295  0.039   1       64
# 
# BFID2   -0.295  11.457  2       65
# BFID2   -11.614 11.457  2       66
# BFID2   -11.693 0.079   2       67
# BFID2   -0.295  0.039   2       68
