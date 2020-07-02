#!/usr/bin/perl -w
##############################################################################
#     Name: matrix_chessboard.pl
#
#  Summary: Demo of matrix datastructures.  Actual chess rules do not apply,
#           just a demo of moving around a grid.
#
#  Adapted: Sat 07 Aug 2004 19:59:12 (Bob Heckel -- Beginning Perl Cozens)
##############################################################################
use strict;

my @chessboard;
my @back = qw(R N B Q K N B R);

for ( 0 .. 7 ) {
  $chessboard[0]->[$_] = "W" . $back[$_]; # white back row
  $chessboard[1]->[$_] = "WP";            # white pawns
  $chessboard[6]->[$_] = "BP";            # black pawns
  $chessboard[7]->[$_] = "B" . $back[$_]; # black back row
  # all the rest are autovivified
}

while ( 1 ) {
  # Print board
  for my $i ( reverse (0 .. 7) ) { # row
    for my $j ( 0 .. 7 ) {       # column
      if ( defined $chessboard[$i]->[$j] ) {
        print $chessboard[$i]->[$j];
      } elsif ( ($i % 2) == ($j % 2) ) {
      print "..";  # checkered effect - place a color marker on a blank square
      } else {
        print "  ";
      }
      print " ";  # End of cell
    }
    print "\n";     # End of row
  }

  print "\nStarting square [x,y]: ";
  my $move = <>;
  last unless ( $move =~ /^\s*([1-8]),([1-8])/ );
  my $startx = $1-1; my $starty = $2-1;
     
  unless ( defined $chessboard[$starty]->[$startx] ) {
    print "There's nothing on that square!\n";
    next;
  }
  print "\nEnding square [x,y]: ";
  $move = <>;
  last unless ( $move =~ /([1-8]),([1-8])/ );
  my $endx = $1-1; my $endy = $2-1;

  # Put starting square on ending square.
  $chessboard[$endy]->[$endx] = $chessboard[$starty]->[$startx];
  # Remove from old square
  undef $chessboard[$starty]->[$startx];
}
