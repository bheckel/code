#!/usr/bin/perl -w
##############################################################################
#    Name: multkey_sort.pl
#
# Summary: Sort using multiple keys
#
# Adapted: Fri 16 Mar 2001 13:40:21 (Bob Heckel -- from RayCosoft website)
##############################################################################

use strict;

# An array of references to anonymous hashes:
my @employees = 
      ( { FIRST => 'Bill',   LAST => 'Gates',   SALARY => 600000, AGE => 45 },
        { FIRST => 'Zach', LAST => 'Testey',  SALARY =>  55000, AGE => 29 },
        { FIRST => 'Sally',  LAST => 'Devel',   SALARY =>  55000, AGE => 29 },
        { FIRST => 'Abe',    LAST => 'Testey',  SALARY =>  55000, AGE => 29 },
        { FIRST => 'Steve',  LAST => 'Ballmer', SALARY => 600000, AGE => 41 },
      );

my @ranked = sort seniority @employees;

print "Sorted by salary, age, last name, first name:\n";
foreach my $emp ( @ranked ) {
  print "$emp->{SALARY}\t$emp->{AGE}\t$emp->{FIRST} $emp->{LAST}\n";
}


sub seniority {
  $b->{SALARY} <=> $a->{SALARY} or 
  $b->{AGE}    <=> $a->{AGE}    or 
  $a->{LAST}   cmp $b->{LAST}   or 
  $a->{FIRST}  cmp $b->{FIRST}
}

