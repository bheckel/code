#!/usr/bin/perl -w
##############################################################################
#    Name: compare_arrays.pl
#
# Summary: Find things in one array list that are not in another.
#          Search an array for for list membership.  Good for smaller lists.
#
#          See diff_arrays.pl for a more complicated approach.
#
# Adapted: Fri 16 Mar 2001 08:54:20 (Bob Heckel -- from RayCosoft website, Perl
#                                    Objects, Reference and Modules)
# Modified: Mon 28 Apr 2014 13:12:46 (Bob Heckel)
##############################################################################

my @required = qw(preserver sunscreen water_bottle jacket);
my @skipperhas = qw(blue_shirt hat jacket preserver sunscreen);

for my $item ( @required ) {
  unless (grep $item eq $_, @skipperhas) { # not found in list?
    print "skipper is missing $item.\n";
  }
}


# Alternative

@old = qw(cat dog man hat glove);
@new = qw(dog ball hat);

%known = map { $_, 1 } @old;

foreach $word ( @new ) {
  if ( not $known{$word} ) {   
    print "$word is not in old list.\n";
  }
}

