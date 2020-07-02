#!/usr/bin/perl
##############################################################################
#     Name: print_before_last_line.pl
#
#  Summary: Write dashed prior to the last line printing.
#
#  Adapted: Fri 08 Dec 2006 10:34:30 (Bob Heckel -- Programming Perl v3)
##############################################################################
use warnings;

while (<>) {
  if (eof()) {
      print "-" x 30, "\n";
  }
  print;
}
