#!/usr/bin/perl
##############################################################################
#     Name: caller.pl
#
#  Summary: Demo of determining who called us
#
#  Adapted: Mon 04 Apr 2011 14:02:57 (Bob Heckel -- Modern Perl chromatic)
##############################################################################
use strict;
use warnings;

sub show_pets {
  my %pets = @_;

  my ($pkg, $file, $line) = caller();
	print "called from $pkg in $file:$line\n";

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
