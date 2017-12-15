#!/usr/bin/perl -w
##############################################################################
#    Name: subscript.pl
#
# Summary: Demo of $; special variable.  See p. 133 Programming Perl 2nd edit.
#
# Created: Tue, 28 Mar 2000 08:10:16 (Bob Heckel)
##############################################################################

###$a1 = 'first';
###$a2 = 'second';
###
###$xxx = join(':', $a1, $a2);
###
###print $xxx;

###%foo = ();
###$foo{ONE} = 'dog';
###$foo{TWO} = 'cat';
###
###print $foo{ONE};

$a = 'x';
$b = 'y';

$bar{'x:y'} = 'bobo';
$zzz = $bar{join(':',$a,$b)};
print $zzz, "\n";
$; = ':';
$xxx = $bar{$a,$b};
print $xxx;

