#!/usr/bin/perl -w
##############################################################################
#  Program: references.pl
#
#  Summary: Demo from "Understand References Today" TPJ.
#           Hash values must be scalars but references allow a way around
#           this backward compatibility restriction.
#           References are a way to name arrays and hashes.
#
#  Created: Tue, 30 Nov 1999 10:08:39 (Bob Heckel)
# Modified: Thu 05 Jul 2001 09:01:19 (Bob Heckel -- now it's called perlreftut)
# Modified: Fri 20 Aug 2004 21:56:36 (Bob Heckel)
##############################################################################

package Dummy;
# does nothing, normally there would be class stuff here
1;


package main;

$a = [];  $b = {} ;  $c = \42;  $d = \$c;

print '$a is a ', ref $a, " reference\n";
print '$b is a ', ref $b, " reference\n";
print '$c is a ', ref $c, " reference\n";
print '$d is a ', ref $d, " reference\n";

# Make reference, $b, know which package it belongs to:
bless $b, 'Dummy';
print 'Now $b is a ', ref $b, " reference (but its still just a hash ref)\n\n";


# New example:

# Build the data structure.
while ( <DATA> ) {
  chomp;
  my ($city, $state) = split /,/;
  # Create hash named %table whose keys are states and values are (references
  # to) arrays of city names.  
  # This line is the same as  push @arr, $city except that the normal array
  # name 'arr' (or actually {arr}) has been replaced by the reference
  # {$table{$state}}
  push @{$table{$state}}, $city;
}

foreach $state (sort keys %table) {
  print "STATE: $state\n";
  # {$table{$state}} is a reference to the list of cities in the state.
  my @cities = @{$table{$state}};
  print join ', ', sort @cities;
  print "\n";
}

__DATA__
raleigh, nc
somerset, new jersey
Westfield, new jersey
