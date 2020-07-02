#!/usr/bin/perl -w
use v5.10;
###$h = { one => [ 'a', 'b', 'c' ], two => [ 'd', 'e', 'f' ] }; print $$h{two}->[1];

@y = qw( a b c);
@z = qw (d e f g);
@x = ( \@y, \@z );

say $x->[0][1];
###require Data::Dumper; print STDERR "DEBUG: ", Data::Dumper::Dumper( @x ),"\n";
