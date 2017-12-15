#!/usr/bin/perl -w

use Carp;

sub add_numbers {
  croak "Expected two numbers, but received: " . @_ unless @_==2;
  print 'ok';
}

###add_numbers(1, 2);
add_numbers(1);
