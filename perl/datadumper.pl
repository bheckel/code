#!/usr/bin/perl
##############################################################################
#     Name: datadumper.pl
#
#  Summary: Print, dump, data structures.
#
#           E.g.
#               use Data::Dumper;
#               print Dumper $myref;
#
#
#  Adapted: Tue, 16 May 2000 13:14:54 (from Effective Perl Debugging Bob
#                                     Heckel)
# Modified: Tue, 20 Jun 2000 13:31:26 (Bob Heckel)
##############################################################################
use warnings;

# Simple:
# use Data::Dumper;print Dumper %foo;

use Data::Dumper;
###$Data::Dumper::Terse = 1;
###$Data::Dumper::Indent = 1;

$a = { H => 1, He => 2, Li => 3, Be => 4 };
print Data::Dumper->Dump([$a],['elementz']);

print "\n\n................\n\n";

# Storing colors as RGB values in anonymous lists.
%COLORS = ('red'  =>[255, 0,   0],
           'green'=>[0,   255, 0],
           'blue' =>[0,   0,   255],
           'white'=>[255, 255, 255] );
# Diff is that this will use $colours = 'blue';
###print Data::Dumper->Dump([%COLORS],['colours']);
# And this will use $VAR1 = 'blue';
print Dumper(%COLORS);


print "\n\n................\n\n";

# Data::Dumper can also handle self-referential structures:
$c = { name => "C" };
$b = { name => "B", nextone => $c };
$a = { name => "A", nextone => $b };
$c->{nextone} = $a;

print Data::Dumper->Dump([$a, $b, $c], [qw(a b c)]);

