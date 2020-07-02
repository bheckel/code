#!/usr/bin/perl -w

# Throw away duplicate elements of an array.
# Works b/c a hash can't have the same key twice.
# Adapted from www.perl.com My Life with Spam 03/22/00

@forwarders = qw(one two one three);
  
foreach $r (@forwarders) {
   $r{lc $r} = 1;
 }

@forwarders = sort(keys %r);
print "@forwarders";

