#!/usr/bin/perl -w

use v5.10;

sub make_sundae {
	my %parms = @_;

	$parms{flavor} //= 'vanilla';
	$parms{topping} //= 'fudge';

	foreach my $k ( sort keys %parms ) { say "$k=$parms{$k}"; }
}

###make_sundae('sprinkles', 100);
# Override default flavor:
make_sundae('flavor', 'chocolate',  'sprinkles', 100);
