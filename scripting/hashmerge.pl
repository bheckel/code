#!/usr/bin/perl
##############################################################################
#     Name: hashmerge.pl
#
#  Summary: Merge, append two hashes together.
#
#  Created: Tue 28 Nov 2006 14:51:55 (Bob Heckel)
# Modified: Thu 17 Apr 2014 14:47:39 (Bob Heckel)
##############################################################################
use warnings;

# Deprecated, use Data::Dumper
###require 'dumpvar.pl'; # if debugging or you want to see the data structures
use Data::Dumper;

%hashx = (one => x1, two => x2, onboth=> both3);
%hashy = (four => x4, onboth => both5);

for ( keys %hashy ) {
  print "BEFORE \%hashy: $_ is $hashy{$_}\n"; 
}

#       ---into--->
Merge(\%hashx, \%hashy);  # on conflict, hashx values override hashy


sub Merge {
  my($dest, $src)  = @_;

###  print Dumper $dest, $src;

  for ( keys %$dest ) {
		# TODO add logic to detect dup key
    $src->{$_} = $dest->{$_};
  }
}

print "---------------------------------\n";
for ( keys %hashy ) {
  print "AFTER \%hashy: $_ is $hashy{$_}\n"; 
}



print "--------without looping----------\n";

%hashx = (one=>'fish', two=>'turtle', onboth=>'carpXtakesprecedence');
%hashy = (four => 'bird', onboth => 'catY', onboth=>'carpY');
# hashy values override hashx
%comb = (%hashx, %hashy);

while ( ($key, $val) = each %comb ) {
  print "$key\t $val\n";
}


print "----------without new hash-----------------\n";
%hashx = (one=>'fish', two=>'turtle', onboth=>'carpXtakesprecedence');
%hashy = (four => 'bird', onboth => 'catY', onboth=>'carpY');
%hashx = (%hashx, %hashy);

while ( ($key, $val) = each %hashx ) {
  print "$key\t $val\n";
}
