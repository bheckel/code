#!/usr/bin/perl -w
##############################################################################
#     Name: unique_file.pl
#
#  Summary: Display unique items in a file.  Skip duplicates.  Case
#           insensitive.
#
#  Created: Wed 06 Jun 2001 09:08:23 (Bob Heckel)
##############################################################################

open FILE, 'junk.txt' || die "$0: can't open file: $!\n";

while ( <FILE> ) {
  next unless /\w+/;
  chomp $_;
  $seen{lc $_}++;   # no duplicate entries
  if ( $seen{$_} < 2 ) {
    $unique .= "$_\n";
  }
} 

close FILE;

print $unique;
