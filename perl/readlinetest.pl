#!/usr/bin/perl -w

use strict;
use Term::ReadLine;

&start_stupid_math_shell;

sub start_stupid_math_shell {
  my $term = new Term::ReadLine 'Simple Perl calc';
  my $prompt = "Enter your arithmetic expression: ";
  
  while ( defined ($_ = $term->readline($prompt)) ) {
    my $res = eval($_), "\n";
    warn $@ if $@;
    print $res, "\n" unless $@;
    $term->addhistory($_) if /\S/;
  }
}
