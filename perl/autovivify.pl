#!/usr/bin/perl -w
##############################################################################
#     Name: autovivify.pl
#
#  Summary: Demo of using (protecting against?) auto-vivification.
#
#  Created: Tue 26 Aug 2003 16:56:41 (Bob Heckel)
##############################################################################

$matrix{0}{2} = 100;
$matrix{1}{0} = 200;
$matrix{2}{1} = 300;

# Risky.
print $matrix{1}{0};

# Could get an auto vivified Heisenbug if you don't do this.
if ( exists $matrix{0} && exists $matrix{0}{2} ) {
  print $matrix{0}{2};
}
