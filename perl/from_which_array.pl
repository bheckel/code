#! /usr/bin/perl

# You have three arrays, each of which is a unique list of numbers, and you
# want to construct @locations as a list of where they came from, in order. 
#
# Adapted: Fri Mar 11 19:20:40 2005 (Bob Heckel --
# http://perlmonks.org/?node_id=438612)

use strict;
use warnings;

my @rep1 = (1..5);
my @rep2 = (6..10);
my @rep3 = (11..15);

my @pairs = map { sprintf "%d %d", int(rand(15)+1), int(rand(15)+1) } 1..10;
print "random pairs: @pairs\n\n";

# Make a list of name-array associations, pass it to map Then go through the
# members of the array and associate each member with the name.
my %sources = map { my ($name, $ref) = @$_; map { ($_ => $name) } @$ref; } 
                        ([rep1 => \@rep1], [rep2 => \@rep2], [rep3 => \@rep3]);

my $i = 0;
for ( @pairs ) {
  print "pair ", $i++, " is $_:   \t\t";
  my ($n1, $n2) = split;
  # Now, when you have a number $n1, its source is $sources{$n1}
  print "$n1 came from $sources{$n1} \t $n2 came from $sources{$n2}\n";
}
