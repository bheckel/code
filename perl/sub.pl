#!/usr/bin/perl
##############################################################################
#     Name: sub.pl
#
#  Summary: Demo of accepting function parameters
#
#  Adapted: Mon 28 Apr 2014 12:34:49 (Bob Heckel -- modern_perl_letter.pdf)
##############################################################################
use warnings;
use v5.10;

sub greet_one {
	my ($name) = @_;
	say "hello $name";
}

sub greet_one_more {
	my $name = shift;
	say "hello $name";
}

sub greet_one_more_more {
	my $name = $_[0];
	say "hello $name";
}


sub greet_all {
	say "hello $_ " for @_;
}

sub greet_all_more {
	my ($hero, $sidekick) = @_;
	say "hello $hero and $sidekick";
}
