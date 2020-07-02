#!/usr/bin/perl -w

# See also hash_of_arrays.pl

while ( <DATA> ) {
  ($bothsize, $name) = split;
  @sizes = split('_', $bothsize);
  # A hash whose keys are text and values are anon arrays of nums
  push @{ $h{$name} }, @sizes;
} 


while ( ($key, $value) = each %h ) {
  print "k " . $key . " and v " . $value;
}
print "\n";

while ( ($key, $value) = each %h ) {
  print "k " . $key . " and v " . @{ $value };
}
print "\n";

use Data::Dumper; print Dumper %h ;


__DATA__
100_222 bob
200_223 foo
300_224 sub/dirhere
400_225 another/subdir
