#!/usr/bin/perl -w

use v5.10;

# Its English.pm mnemonic is $LIST_SEPARATOR, defaulting to a single space
###local $" = '( )';
local $" = '| |';

@food = qw(pie cookie lard);

###say "(@food)";
say "|@food|";

