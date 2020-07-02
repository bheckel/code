#!/usr/bin/perl -w
##############################################################################
#     Name: print_pad_repetition.pl
#
#  Summary: Display using dots to separate the varibles using the binary
#           string repetition operator 'x'
#
#  Created: Wed 06 Nov 2002 15:56:33 (Bob Heckel)
##############################################################################
use strict;

my %h = qw(k1 1 k2 2 k3 3);

my $width = 40;  # half a screen

printf "%s%s%s\n", 'Path', '.' x ($width-length('Hits')), 'Hits';

foreach my $key ( sort keys %h ) {
  my $lng = $width-length($key);
  printf "%s%s%2d\n", $key, '.' x $lng, $h{$key};
}
