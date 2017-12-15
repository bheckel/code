#!/usr/bin/perl -w
##############################################################################
#     Name: array_binary_search.pl
#
#  Summary: Search an array for for list membership. Efficient for large lists.
#
#  Adapted: Sat 30 Apr 2005 09:44:37 (Bob Heckel -- Modern Perl chromatic)
# Modified: Mon 28 Apr 2014 13:26:02 (Bob Heckel)
##############################################################################

sub elem_exists {
	my ($item, @array) = @_;

	# Stop recursion when no elements remain to search
	return unless @array;

	# Bias down with odd number of elements
	my $midpointelem = int( (@array / 2) - 0.5 );
	my $miditem = $array[ $midpointelem ];
print "DEBUG: miditem of midpointelem [$midpointelem] in (@array) is $miditem\n";

  # DETERMINED:
	# Return true if found
	return 1 if $item == $miditem;
 	# Otherwise return false since only one element remains
	return if @array == 1;

  # INDETERMINED:
	# If we're below the miditem, split the array downward then keep searching by
	# recursion 
	return elem_exists($item, @array[ 0 .. $midpointelem ]) if $item < $miditem;
	# Otherwise split the array and keep searching by recursion
	return elem_exists($item, @array[ $midpointelem + 1 .. $#array ]);
}

my @elements = (1, 5, 6, 19, 48, 77, 997, 1025, 7777, 8192, 9999);
# Only takes 3 iterations instead of average of 5 using non-binary approach
print 'found' if elem_exists(1025, @elements);  
