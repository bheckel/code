#!/usr/bin/perl -w
##############################################################################
#     Name: hash_of_arrays.pl
#
#  Summary: Demo of using a hash of arrays as a data structure.
#
#           See also hash_with_pushed_anonarray.pl
#
#  Adapted: Wed 10 Dec 2003 10:42:38 (Bob Heckel --
#                               file:///C:/Perl/html/lib/Pod/perldsc.html)
# Modified: Mon 12 Mar 2007 13:43:34 (Bob Heckel)
##############################################################################
use strict;

#           ------------array element-------------------
#           ----key----    ----------value--------------
#                          ----anon array------
my %HoA = ( flintstones => [ "fred", "barney" ],
            jetsons     => [ "george", "jane", "elroy" ],
            simpsons    => [ "homer", "marge", "bart" ],
          );

# Jane
print $HoA{jetsons}[1], "\n";
print "\n";

for my $show ( keys %HoA ) {
  print $show, "\n";
}
print "\n";

for my $character ( values %HoA ) {
  # ARRAY(0xa0280dc)
  print $character, "\n";
  # The '@' is referring to the anon arrays (values in this example). TODO
  # right?
  print @$character, "\n";
  # Same?
  print @{ $character }, "\n";
  # Same but separate array elements with spaces.
  print "@{ $character }", "\n";
}

# Append new characters to a show's array:
push @{ $HoA{simpsons} }, "apu", "maggie";
print $HoA{simpsons}[4];
print "\n\n";


####################################################################
# Now build the HoA from file:
while ( <DATA> ) {
  next unless s/(\w+):\s*(\w+)/$2/;
  ###@{ $HoA{$1} } = split;
  # same
  $HoA{$1} = [ split ];
}

print 'characters (values in the hash) ';
for my $characters ( values %HoA ) {
  print "@{ $characters }", "\n";
}

use Data::Dumper; print Dumper %HoA; 



__DATA__
flintstones: fred barney
jetsons:     george jane elroy
simpsons:    homer marge bart
