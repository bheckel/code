#!/usr/bin/perl -w

use v5.10;

do {
	say 'What is your name?';
	my $name = <>;
	chomp $name;
	say "Hello, $name!" if $name;
} until (eof);
