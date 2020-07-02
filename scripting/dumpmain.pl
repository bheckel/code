#!/usr/bin/perl
##############################################################################
#     Name: dumpmain.pl
#
#  Summary: Copy into code to see a very messy symbol table.  Similar to a 
#           SAS log.
#
#  Adapted: Fri 24 Aug 2007 11:38:03 (Bob Heckel)
##############################################################################

$x=10;
@y=(1,2,3);
%z=(a,b,c,d);

#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
open FH, '>junkdumpmain' or die "Error: $0: $!";
foreach $symname (sort keys %main::) {
  local *sym = $main::{$symname};
  print FH "\$$symname is $$symname\n" if defined $sym;
  print FH "\@$symname is @$symname\n" if defined @sym;
  ###while ( (my $k, my $v) = each %$symname ) { print FH "$k is $v\n" if defined %sym; }
}
#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
#~~~~~~DEBUG~~~~DUMP~~~~~~DEBUG~~~~DUMP~~~
