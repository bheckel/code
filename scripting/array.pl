#!/usr/bin/perl
##############################################################################
#     Name: array.pl
#
#  Summary: Demo of array manipulation, undef, slices, etc.
#
#           A Perl list is a sequence of comma separated values, usually
#           in parentheses.  They are commonly used to initialize arrays.
#
#           A Perl array is a *container* for a list.
#
#  Created: Thu, 25 Nov 1999 12:42:19 (Bob Heckel)
# Modified: Wed 14 Mar 2007 10:24:52 (Bob Heckel)
##############################################################################

@rainbow = ("a".."z");
my @slice = @rainbow[0 .. $#rainbow-5];


@array = ("A", "Two", "Three", "Four");
# Direct copy assignment is ok
@a2 = @array;
$a3[0] = 'foo'; 
# This does not DWIM, but instead puts the count of array elements into [1]
$a3[1] = @array;
# This does DWIM:
$a3[1] = \@array;
print "\@a3 is @a3\n";
print "\$a3[1][0] is $a3[1]->[0]\n\n";

@concatenated = "@array @a2";
# same
push @concatenated, @array, @a2;
# same
@concatenated = (@array, @a2);
print "concatenated: @concatenated\n";


#   not @ !
print $array[0], " is A\n";
#     ^

# Use an array slice to assign the first and third elements to $first and
# $third.
($first, $third) = @array[0, 2];

# Use an array slice to assign the second half of the array to @secondhalf.
@secondhalf = @array[2, 3];

print "\n\@array=@array\n";

print "\$first=$first  \$third=$third\n";

print "\@secondhalf=@secondhalf\n";

# Tranpose the first and last elements in @array.
@array[0, 3] = @array[3, 0];

print "Transposed 1st and 4th: \@array=@array\n";

print "###################################\n\n";

@numbs = 1 .. 10;
undef $numbs[9];
# Still the same number of elements.
print scalar(@numbs), " after undefing\n";
pop(@numbs);
print scalar @numbs, " after popping.\n";
@numbs = ();
print scalar @numbs, " after purging.\n";


# Turn string into an array:
$s = 'convert string into array';
while ( $s =~ m/(\S+)/g ) {
  push @words1, $1;
}
print "@words1\n";

# or better for simple whitespace separated values:
@words2 = split /\s+/, $s;
print "@words2\n";

# same
foreach ( @words2 ) { print; }; print "\n";
# same
for ( @words2 ) { print; }; print "\n";
# same
print foreach @words2; print "\n";
# same
map { print } @words2; print "\n";
