#!/usr/bin/perl -w

# Adapted: Tue 15 Apr 2014 10:26:11 (Bob Heckel -- modern_perl_letter.pdf)

use v5.10;

my @options = ( \&rock, \&paper, \&scissors );
my $confused = "I don't understand your move";

do {
	say "go";
	chomp(my $userchoice=<>);
	my $computerchoice = $options[ rand @options ];
	$computerchoice->(lc($userchoice));
} until (eof);

sub rock {
	print "I chose rock - ";
	
	for ( shift ) {
		when ( /paper/ )    { say 'you win' };
		when ( /rock/ )     { say 'tie' };
		when ( /scissors/ ) { say 'I win' };
		default             { say $confused };
	}
}

sub paper {
	print "I chose paper - ";
	
	for ( shift ) {
		when ( /paper/ )    { say 'tie' };
		when ( /rock/ )     { say 'I win' };
		when ( /scissors/ ) { say 'you win' };
		default             { say $confused };
	}
}

sub scissors {
	print "I chose scissors - ";
	
	for ( shift ) {
		when ( /paper/ )    { say 'I win' };
		when ( /rock/ )     { say 'you win' };
		when ( /scissors/ ) { say 'tie' };
		default             { say $confused };
	}
}
