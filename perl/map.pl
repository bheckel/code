#!/usr/bin/perl -w
##############################################################################
#     Name: map.pl
#
#  Summary: The map() function is like a rubber stamp applied to all elements
#           of a list.
#
#           my @foo = map { transform($_) } grep { -f $_ } @list;
#
#  Created: Wed 10 Oct 2001 17:34:19 (Bob Heckel)
# Modified: Sun 17 Apr 2005 08:45:25 (Bob Heckel)
##############################################################################

@lines = ('abcXdefXghi','jklXmb','nopXqc','rstXud');
@words = map { split 'X' } @lines;
print "@words\n";
print $words[2], " <---s/b ghi\n\n";

map { print if $_ ne 'abcXdefXghi' } @lines;

#######################################

# Another demo:
# Can use this:
foreach $num (1 .. 10) {
  push @squares, ($num**2);
}
print "foreach loop approach:  @squares\n\n";

# Or this:
###@num2 = (1 .. 10);
###@squares2 = map { $_**2 } @num2;
# Better:
@squares2 = map { $_**2 } 1 .. 10;
print "map approach:\t\t @squares2\n";

######################################

# Increment each element by one.
@array = (0 .. 3);
@result = map($_ + 1, @array);
print("Before map: @array\n");
print("After  map: @result\n");

# Print all elements in a list.
@array = ('One', 'Two', 'Three', 'Four', 'Five');
map print("$_\n"), @array;

# Gather filesizes:
@f = qw(junk test.html test.pl);
###@s = map { -s $_ } @f;
@s = map { -s } @f;
print "@s";

######################################

$start = 'Sun'; $end = 'Mon';
%mapping = (Sun => 0, Mon => 1, Tues => 2);

my ($number_for_start, $number_for_end) = map { $mapping{$_}; } $start, $end;

print "\n$number_for_start is start ($start) and" .
      " $number_for_end ($end) is end.\n";

######################################

# Create an array of sequential items quickly:
@hosts = map "10.0.1.$_", 1 .. 254;
print "@hosts";
