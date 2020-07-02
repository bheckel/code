#!/usr/bin/perl
##############################################################################
#     Name: compare_symmetric_difference.pl
#
#  Summary: Compare two files using SET operations
#
#           Symmetric difference: the set of elements belonging to one but not
#           both of two given sets. It is therefore the union of the complement
#           of A with respect to B and B with respect to A, and corresponds to
#           the XOR operation in Boolean logic. 
#
#           Warning: will not detect duplicates
#
#  Created: Thu 14 Feb 2013 16:03:22 (Bob Heckel)
# Modified: Fri 16 Aug 2013 08:43:54 (Bob Heckel)
##############################################################################
use warnings;

open FH1, "$ARGV[0]" or die "Error: $0: $!"; @one = <FH1>;
open FH2, "$ARGV[1]" or die "Error: $0: $!"; @two = <FH2>;

my @union = keys %{ { map {$_ => 1} @one, @two } };

my %one = map { $_ => 1 } @one;
my %two = map { $_ => 1 } @two;

# DEBUG
###print keys %one;
###print values %one;
###print "\n---\n";
###print keys %two;
###print values %two;

#   in1andin2
my @intersect = grep {  $two{$_} } @one;
my @in1notin2 = grep { !$two{$_} } @one;
my @in2notin1 = grep { !$one{$_} } @two;
###my @symdiff = ( (grep { !$two{$_} } @one), grep { !$one{$_} } @two );
# same
my @symdiff = ( @in1notin2, @in2notin1 );

# Flatten column lists newlines into rows for aesthetic presentation only:
map { s/[\r\n]+$//; } @union, @one, @two, @intersect, @in1notin2, @in2notin1, @symdiff;

print "\n\nunion (distinct):\n@union";
print "\n\nunion all:\n@one @two";
print "\n\nintersection:\n@intersect";
print "\n\nin 1 but not in 2:\n@in1notin2";
print "\n\nin 2 but not in 1:\n@in2notin1";
print "\n\nsymmetric diff:\n@symdiff";    # inner joinish
print "\n\n";



__END__
junk1:
garfield
JAGUAR
LEOPARD
lion
tiger

junk2:
baboon
elephant
hippo
JAGUAR
LEOPARD
lion
mamba


in 1, not in 2:
tiger
garfield

symmetric difference:
tiger
garfield
elephant
hippo
baboon
mamba


__END__

junk1:
0695017
0695009
0695025
9999999

junk2:
0695009
0695017
0695025
0696005
