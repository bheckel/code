#!/usr/bin/perl
##############################################################################
#     Name: fortune.pl
#
#  Summary: Randomly print rotated paragraphs.
#
#  Created: Fri 25 Aug 2006 11:14:22 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

open FH, 'junk' or die "Error: $0: $!";

###local $/ = '---';
local $/ = '';  # "paragrep" slurp
@paragraphs = <FH>;
$npgs = @paragraphs - 1;

###$paragraphs[1] =~ s/---//g;
###print $paragraphs[1];
###print $paragraphs[2];
###print $paragraphs[0];
$n = 0;
for $paragraph ( @paragraphs ) {
  ###$paragraph =~ s/---//g;
  $paragraph =~ s/[\r\n]+$//;
  $tmp = $paragraph if $n == 0;
  print "$paragraph\n\n" if $n != 0;
  print "$tmp\n\n" if $n == $npgs;
  $n++;
}



__DATA__
first paragraph
is this 
---
second paragraph
is this 
---
third paragraph
is this 
---
