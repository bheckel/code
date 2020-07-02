#!/usr/bin/perl

# Poor man's tac(1)

use strict;
use warnings;

open FH, '+<junk.txt' or die "Error: $0: $!";
print FH reverse <FH>;

__END__
# Or if want to leave original as is:

open FH, 'junk.txt' or die "Error: $0: $!";
open FH2, '>junk2.txt' or die "Error: $0: $!";

print FH2 reverse <FH>;
