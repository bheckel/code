#!/usr/bin/perl -w
##############################################################################
#    Name: reorder_elements.pl
#
# Summary: Reorder elements of an array.
#
# Created: Sat, 10 Jun 2000 22:23:11 (Bob Heckel)
# Modified: Wed 21 Apr 2004 17:21:25 (Bob Heckel)
##############################################################################
use strict;

my @records = qw(one1 two2 three3 four4 five5 six6);
# Want $record[2] moved after $record[4] and then reorder the digits ascending.
print &Reorder_elements(2, 4, @records);


sub Reorder_elements {
  my($from, $below, @records) = @_;
  my $realbelow = $below;

  $from--;
  $below--;

  my $movethis = splice(@records, $from, 1);

  my @newone = ();
  my $i = '';
  # Relocate.
  foreach my $element ( @records ) {
    $i++;
    $i == $realbelow ? push(@newone, $movethis, $element) 
                     : push(@newone, $element);
  }

  my $j = 1;
  # Renumber.
  foreach my $element ( @newone ) {
    $element =~ s/\d+$/$j/;
    $j++;
  }
    
  return @newone;
}

