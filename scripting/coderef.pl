#!/usr/bin/perl -w
##############################################################################
#     Name: coderef.pl
#
#  Summary: Using closures to return bits of code from subroutines.  This 
#           creates coderefs on the fly which will multiply by whatever number
#           you decide via STDIN.
#
#  Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place tut 
#                                     Lesson 07)
##############################################################################
use strict;

my $n = <STDIN>;

my $coderef_two = Multiplier($n);
my $coderef_three = Multiplier($n);

print "times two: ", $coderef_two->(2), "\n";
print "times three: ", $coderef_three->(3), "\n";


sub Multiplier {
  # When you use...
  #   $coderef->(2);  
  #
  # or equivalently but messier:
  #   &{ $coderef }(2);  <--- '&' is the sigil for subroutines
  #
  # ...the value of $number you entered when you constructed the coderef is
  # still there, deeply bound into the coderef, even though it "shouldn't"
  # really exist outside the scope of sub Multiplier.
  my $number = shift;

  my $coderef = sub { return $number * $_[0] };

  return $coderef;
}
