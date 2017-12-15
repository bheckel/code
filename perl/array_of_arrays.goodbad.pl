#!/usr/bin/perl -w
##############################################################################
#     Name: array_of_arrays.goodbad.pl
#
#  Summary: Demo of correctly placing arrays into an array using references.
#
#  Adapted: Tue 09 Dec 2003 16:41:31 (Bob Heckel --
#                                  file:///C:/Perl/html/lib/Pod/perldsc.html)
##############################################################################
###use strict;

print "Wrong:\n";
for my $i ( 0..9 ) {
  @array = Retarr($i);
  $AoA[$i] = \@array;      # wrongly only keeps the 10th iteration!
  print $AoA[$i];
}

# Bb9
print "\n", $AoA[0][1], "\n";
# Bb10
print $AoA[1][1], "\n\n";


print "\nRight:\n";
for my $i ( 0..9 ) {
  ###@array = Retarr($i);
  # The square brackets make a reference to a new array with a COPY of what's
  # in @array at the time of the assignment.
  ###$AoA[$i] = [ @array ];
  # Better but more confusing:
  $AoA[$i] = [ Retarr($i) ];
  print $AoA[$i];
}

# Add to an existing row:
push @{ $AoA[4] }, 'add', '3 more', 'elements onto the ref';

# Bb0
print "\n", $AoA[0][1], "\n";
# Cc1
print $AoA[1][2], "\n\n";

for my $i ( 0..9 ) {
  for my $j ( 0..2 ) {
    print $AoA[$i][$j], " ";
  }
  print "\n";
}


sub Retarr {
  return "Aa$_[0]", "Bb$_[0]", "Cc$_[0]";
}
