#!/usr/bin/perl -w
##############################################################################
#     Name: not_in_list.pl
#
#  Summary: Determine which item is not found in the Skipper's bag.
#
#  Adapted: Sat 26 Jul 2003 13:05:35 (Bob Heckel -- Perl References & Objects)
##############################################################################

my @required = qw(preserver sunscreen water_bottle jacket);
my @skipper = qw(blue_shirt hat jacket preserver sunscreen);

for my $item ( @required ) {
  unless ( grep $item eq $_, @skipper ) {  # not found in list
    print "skipper is missing $item.\n";
  }
}
