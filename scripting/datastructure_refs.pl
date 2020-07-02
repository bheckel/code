#!/usr/bin/perl -w

# Experimenting with PEGS Perl Graphical Structures.

# p. 11 Named hash of references to lists.
$refa = ['cat0', 'dog1', 'horse2'];
$refb = ['dagney0', 'roark1', 'toohey2'];
$refc = ['eeny0', 'meeny1', 'miny2'];

%h = (animales => $refa,
      atlases  => $refb,
      craps    => $refc);

###print keys %h;
print values %h;  # anonymous arrays
print "\n\n";
print $h{animales}->[2];
###print $h{animales}[2];
