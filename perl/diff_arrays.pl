#!/usr/bin/perl -w
##############################################################################
#    Name: diff_arrays.pl
#
# Summary: Demo of determining differences between 2 arrays.
#          See compare_arrays.pl for a simpler approach.
#
# Adapted: Sun, 24 Dec 2000 12:19:53 (Bob Heckel -- Unix Review col 35)
##############################################################################

# Approach 1 (can't handle duplicates).  From perlfaq4.
@one = qw(a b c d e f g);
@two = qw(b c e h i j);

@union = @intersection = @difference = ();
%count = ();
foreach $element (@one, @two) { $count{$element}++ }
foreach $element (keys %count) {
    push @union, $element;
    push @{ $count{$element} > 1 
            ? \@intersection 
            : \@difference }, $element;
}
print "Intersection: @intersection\n";
print "Difference: @difference\n\n";


# Approach 2.  From UnixReview col35.
  @one = qw(a a a a b c d e f g);
  @two = qw(b c e h i i i i j);
  my %tracker = ();
  $tracker{$_} .= 1 for @one;
  $tracker{$_} .= 2 for @two;
  for (sort keys %tracker) {
    if ($tracker{$_} !~ /1/) {
      print "$_ should be added\n";
    } elsif ($tracker{$_} !~ /2/) {
      print "$_ should be deleted\n";
    } else {
      print "$_ is in both old and new\n";
    }
  }

