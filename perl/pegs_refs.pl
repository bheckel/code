#!/usr/bin/perl -w

# Experimenting with PEGS Perl Graphical Structures.

# p. 11 Named hash of references to lists.
$refa = ['cat0', 'dog1', 'horse2'];
$refb = ['dagney0', 'roark1', 'toohey2'];
$refc = ['eeny0', 'meeny1', 'miny2'];

%a = (animales => $refa,
      atlases  => $refb,
      craps    => $refc);

###print keys %a;
###print values %a;
print $a{animales}->[0];
