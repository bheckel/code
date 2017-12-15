#!/usr/bin/perl -w
##############################################################################
#     Name: array_of_arrays_input.pl
#
#  Summary: Parse input of user's input lines from the keyboard into words.  
#           One anonymous array is created per line entered.
#
#  Adapted: Fri 08 Aug 2003 15:39:40 (Bob Heckel --
#                         http://www.perldoc.com/perl5.6/pod/perllol.html)
##############################################################################

print "Enter 3 words per line (3 times)...\n";
# Use this if you don't want to key the 9 elements (have to delete the next
# FOR loop if so).
@aoa = ( [ 'one', 'two', 'thre' ],
         [ 'f', 'fv', 's' ],
         [ 23, 45, 67 ]
       );

# Better for specific number of iterations:
###for $i ( 0 .. 2 ) {
###  ###$line = <>;
###  # The ' ' in split is mandatory.
###  ###$aoa[$i] = [ split ' ', $line ];
###  # Better, no temp varis?
###  $aoa[$i] = [ split ' ', <> ];
###}  
###print "...done\n";

# Better for general purpose but requires a Ctr-d from user:
while ( <> ) {
  push @aoa, [ split ];
}

print $aoa[0][1], "\n";
print $aoa[1][2], "\n";

for $ref ( @aoa ) {
  print "@{$ref}\n";
}
print "\n";
# or
for $i ( 0 .. $#aoa ) {
  print "@{$aoa[$i]}\n";
}
