#!/usr/bin/perl -w

require 'average-lib.pl';

@a = ();

###while ( <STDIN> ) {
for ( 1 .. 4 ) {
  chomp $_;
  push @a, $_;
}

Avg(\@a);

