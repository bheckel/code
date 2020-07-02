#!/usr/bin/perl -w

# Put new array items at the front of the array.

@array = qw(a b c);
print 'popped @array now has ', pop(@array), " elements: @array\n";

@array = qw(a b c);
print 'shifted @array now has ', shift(@array), " elements: @array\n";

@array = qw(a b c);
print 'unshifted @array now has ', unshift(@array, 1, '2foo', 3), " elements: @array\n";

# Both pop and shift are both O(1) operations on Perl's dynamic arrays. In the
# absence of shifts and pops, push in general needs to reallocate on the order
# every log(N) times, and unshift will need to copy pointers each time.
