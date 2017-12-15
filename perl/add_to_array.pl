#!/usr/bin/perl -w

# Cram additional items into the front an existing array.
@thearray = (1..4);
$nextscalar = "five";

# These 2 are the same, returning  five 1 2 3 4
###@thearray = ($nextscalar, @thearray);
unshift(@thearray, $nextscalar);

# This one puts it on the other end, returning  1 2 3 4 five
###push(@thearray, $nextscalar);

print "@thearray\n";

# Or just concatenate, combine, arrays:
@unique2 = (1..4);
@unique4 = (5..7);
@unique7 = (8..9);
@tmpx = (@unique2, @unique4, @unique7);
print "@tmpx\n";

# Or push them if you're in an iterative loop and don't know the names of all
# the arrays at runtime.
push(@z, @unique2, @unique7);
print "@z\n";
