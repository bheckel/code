#!/usr/bin/perl -w

# Created: Fri, 26 May 2000 17:36:18 (Bob Heckel)
# How to skip specific lines or ranges of lines.

open(JUNK, '/todel/junk');
while(<JUNK>) {
  next if 1 .. 2;
  next if $. == 5;
  print;
}
