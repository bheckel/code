#!/usr/bin/perl -w
##############################################################################
#     Name: hash_arr_refs.pl
#
#  Summary: Demo of using a data structure that allows a named key to be
#           associated with more than one named values.
#
#           Extends on a hash's named key to ONE named value concept.
#
#  Created: Tue 29 Apr 2003 12:54:55 (Bob Heckel)
##############################################################################

# The 3 games played during Week 1:
# Anonymous hash reference (clues: braces instead of parens and $games1
# instead of %games1).  After the hash is built, a reference to it is returned
# in $games1.
$games1 = {
  fred   => [ 101, 102, 103 ],
  barney => [  72,  74, 76 ],
};  # <---don't forget

# The 3 games played during Week 2:
# games2 is handled later without using a temp variable.

# The 3 games played during Week 3:
$games3 = {
  fred   => [ 100, 150, 200 ],
  barney => [ 172, 182, 192 ],
};

print "What were fred and barney's scores in game 3?:\n";
# Warning: don't know whether fred or barney's scores will list first.  You'd
# have to say  'for ( 'barney', 'fred' ) ...'  to be sure.
for ( keys %$games3 ) {
  print "Iterating key: $_\n";
  #         hash
  #      ___________
  print $$games3{$_}->[0] . "\n";
  print $$games3{$_}->[1] . "\n";
  print $$games3{$_}->[2] . "\n\n";
}


# Hold all 3 week's 3 games in one normal, named, array.
my @weeks = ();
$weeks[0] = $games1;
$weeks[1] = { fred   => [ 201, 202, 203 ],
              barney => [ 189, 252, 99 ],
           };
$weeks[2] = $games3;


$wk = 1;
$gm = 3;
print "What was Fred's score on week $wk in game $gm?\n";
# All do the same.
#print $weeks[0]{fred}[1];
#print $weeks[0]->{fred}->[1];
#print $weeks[0]->{fred}[1];
#print $weeks[$wk-1]{fred}[$gm-1];
# Best:
print $weeks[$wk-1]->{fred}->[$gm-1] . "\n";
