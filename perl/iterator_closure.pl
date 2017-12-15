#!/usr/bin/perl
##############################################################################
#     Name: iterator_closure.pl
#
#  Summary: Demo of an iterator that uses a closure
#
#  Adapted: Wed 30 Apr 2014 14:24:50 (Bob Heckel--Modern Perl chromatic)
##############################################################################
use strict;
use warnings;

use v5.10;

sub make_iterator {
	my @items = @_;
	my $count = 0;

	return sub {
		return if $count == @items;
		return $items[ $count++ ];
	}
}

my $cousins = make_iterator(qw(
	Rick Alex Kaycee Eric Corey Mandy Christine Alex
));

# $cousins has closed over the values as they existed with the invocation of make_iterator
say $cousins->();  # Rick
say $cousins->();  # Alex
###say $cousins->() for 1 .. 6;  # everyone
