#!/usr/bin/perl
##############################################################################
#     Name: Ini_test.pl (see also lookuphash.pl)
#
#  Summary: Read ini, lookup to see if X contains Y
#
#  Created: Mon 24 Sep 2007 16:48:09 (Bob Heckel)
##############################################################################
use strict;
use warnings;

use Ini;

my $ini=new Ini;
unless ($ini->read('bob.ini')) {
  die 'Error: No ini file available.';
}


sub XhasY {
  my ($x, $y) = @_;
  my (%commalst, %lookup, %found);

  # e.g. @keys = ('alm5', 'dwj2');
  my @keys = split /\s*,\s*/, $ini->{FooSect}{list};

  for ( @keys ) {
    # e.g. $commalst{alm5} = 'co, dc, hi';
    $commalst{$_} = $ini->{FooSect}{$_};
  }

  # Build something like
  #  %lookup = ( alm5 => [ 'co', 'dc', 'hi', 'id', 'ks', 'mo', 'nc',
  #                        'nm', 'or', 'ri', 'sd', 'tn', 'ut', 'vt',
  #                        'wa', 'wi'
  #                      ],
  #              ces0 => [ ],
  #              dwj2 => [ 'ca', 'fl', 'ga', 'in', 'md', 'mt', 'ny', 'tx',
  #                        'va', 'wc'
  #                      ],
  #              vdj2 => [ 'al', 'as', 'az', 'de', 'gu', 'la', 'ma', 'me',
  #                        'mp', 'nh', 'nj', 'oh', 'ok', 'vi'
  #                      ],
  #            );
  for ( @keys ) {
    $lookup{$_} = [ split /\s*,\s*/, $commalst{$_} ];
  }

  while ( (my $k, my $v) = each %lookup ) {
    for my $state ( @{$v} ) {
      $found{$k}++ if $state eq $y;
    }
  }

  $found{$x} ? return 1 : return 0;
}

print 'dwj2 has fl' if XhasY('dwj2', 'fl');
print "\n";
print 'alm5 has fl' if XhasY('alm5', 'fl');


__END__
bob.ini:

[FooSect]
list=alm5,dwj2
alm5=co,dc,hi
dwj2=ca,fl,ga
