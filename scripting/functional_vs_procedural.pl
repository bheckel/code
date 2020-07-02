#!/usr/bin/perl -w
##############################################################################
#     Name: functional_vs_procedural.pl
#
#  Summary: Demo of two styles of programming.
#
# Adapted: Fri 24 May 2002 08:28:21 (Bob Heckel -- IBM DevWorks Teodor 
#                                    Zlatanov)
# Modified: Wed May 29 16:56:43 2002 (Bob Heckel)
##############################################################################

# "Normal" (procedural) way.
foreach (sort keys %ENV) {
  print "$_ => $ENV{$_}\n";
}

print "\n\n";

# FP way
map { print "$_ => $ENV{$_}\n" } sort keys %ENV;

print "\n\n";

############ Or ################

my @list = (1, 2, 3, 'hi');
my @results;

# "Normal" (procedural) way.
foreach (@list) {
  push @results, $_ unless $_ % 2;
} 
# Using grep - FP approach
@results = grep { !($_ % 2) } @list
