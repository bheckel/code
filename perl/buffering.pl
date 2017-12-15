#!/usr/bin/perl -w

# perljunk.pl
# Demo of flushing output.
# Adapted Thu, 11 May 2000 13:24:41 (Bob Heckel -- Perl Cookbook p. 248)

# Buffered if you call pgm with an arg.
$| = (@ARGV > 0);
print "AAA Buffering in use if you see this line by itself.";
sleep 2;
print "BBB Second half of the line.\n";

