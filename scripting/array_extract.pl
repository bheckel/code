#!/usr/bin/perl -w

# Adapted from p. 114 Perl Cookbook.
# Modified: Wed 16 May 2001 15:05:03 (Bob Heckel)

@x = qw(abc def .no ok);

# Remove dotfile from an array.
@good = grep { /^\w/ } @x;
# Or, to avoid temp variable:
# @x = grep { /^\w/ } @x;

print "@good";

##############

@y = ('abc', undef, '', 'def');

# Remove empty or undef elements from an array:
@y = grep { !/^$/ } @y;

print "\n@y\n";
print scalar(@y), " elements remain in \@y\n"
