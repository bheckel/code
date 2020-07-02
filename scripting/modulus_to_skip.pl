#!/usr/bin/perl -w
##############################################################################
#     Name: modulus_to_skip.pl
#
#  Summary: Demo of the modulus ( modulo ? ) operator.
#
#  Adapted: Mon, 03 Jul 2000 15:15:31 (Bob Heckel)
# Modified: Wed 06 Nov 2002 13:13:02 (Bob Heckel)
##############################################################################

# Print every 3000th line:
$i = 1;
while ( <FILE> ) {
  print $_ if ($i++ % 3000) == 0;
}


# Operate on every 10th line:
while ( <ARGV> ) {
  next unless ($. % 10) == 0;
  print "Do what you want to $_\n";
}


# Demo of actual modulo return values:
for ( $index=0; $index<=10; $index++ ) {
  $result = $index % 5;
  print "$index % 5 is $result\t";
  print "I.e. $index divided by 5 has a remainder of $result\n";
}
print "\n";


# The expression rand() % 6 produces random numbers in the range 0 to 5, and
# rand() % 6 + 1 produces random numbers in the range 1 to 6. 
for ( $i=0; $i<50; $i++ ) {
  $x = rand($i) % 6;
  print $x, " ";
}
print "\n";
