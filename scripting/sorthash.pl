#!/usr/bin/perl -w
##############################################################################
#    Name: sorthash.pl
#
# Summary: Demo of sorting hashes.
#
# Adapted: Sun, 03 Dec 2000 13:48:31 (Bob Heckel -- from PerlArchive.com)
##############################################################################

$sorttype = 'ascend_alpha';

# Use with alpha sorts.
%hash = (
  Apples     => 1,
  apples     => 4,
  artichokes => 3,
  Beets      => 9,
);

# Use with numeric sorts.
###%hash = (
###  2 => 1,
###  3 => 4,
###  2 => 3,
###  8 => 9,
###);

print "Sort asciibetically:\n";
foreach my $key (sort keys %hash){
  print "$key = $hash{$key}\n";
}

print "\n";

print "Sort $sorttype:\n";
foreach my $key (sort $sorttype keys %hash){
  print "$key = $hash{$key}\n";
}

sub ascend_num {$a <=> $b}
sub descend_num {$b <=> $a}
sub ascend_alpha {lc($a) cmp lc($b)}
sub descend_alpha {lc($b) cmp lc($a)}
sub ascend_alphanum {$a <=> $b || lc($a) cmp lc($b)}
sub descend_alphanum {$b <=> $a || lc($b) cmp lc($a)}
