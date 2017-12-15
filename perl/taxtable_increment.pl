#!/usr/bin/perl -w
##############################################################################
#    Name: taxtable_increment.pl
#
# Summary: Used to populate tax table in 99taxes.xls.  Output copied and
#          pasted into spreadsheet.
#
# Created: Sat, 19 Feb 2000 21:43:47 (Bob Heckel)
##############################################################################

for ( $i=20000; $i<=60000; $i++ ){
  unless ( $i % 50 ) {
    $j = $i;
    print "$j\n";
    print "$i\n";
  }
}

