#!/usr/bin/perl
##############################################################################
#     Name: flattened_hashes.pl
#
#  Summary: Demo of the automatic Perl flattening of hashes
#
#  Adapted: Mon 04 Apr 2011 14:02:57 (Bob Heckel -- Modern Perl chromatic)
##############################################################################
use strict;
use warnings;

# The hash assignment inside the function show_pets() works essentially as the
# more explicit assignment to %pet_names_and_types does.
sub show_pets {
  my %pets = @_;

  while ( my($name,$type) = each %pets ) {
    print "$name is a $type\n";
  }
}

my %pet_names_and_types = (
  Lucky=>'dog',
  Rodney=>'dog',
  Tuxedo=>'cat',
  Petunia=>'cat',
);

show_pets(%pet_names_and_types);
