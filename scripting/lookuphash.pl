#!/usr/bin/perl -w
##############################################################################
#     Name: lookuphash.pl (see also Ini_test.pl)
#
#  Summary: Search a hash holding anonymous arrays for a single piece of
#           information.
#
#  Created: Thu 29 Jul 2004 09:26:55 (Bob Heckel)
# Modified: Mon 24 Sep 2007 12:56:18 (Bob Heckel)
##############################################################################
###use strict;
###
###my %stats = ( alm5 => [ 'co', 'dc', 'hi', 'id', 'ks', 'mo', 'nc',
###                        'nm', 'or', 'ri', 'sd', 'tn', 'ut', 'vt',
###                        'wa', 'wi'
###                      ],
###              bxj9 => [ 'ak', 'ar', 'ct', 'ia', 'il', 'ky', 'mi', 'mn',
###                        'ms', 'nd', 'ne', 'nv', 'pr', 'sc', 'wv', 'wy'
###                      ],
###              ces0 => [ ],
###              dwj2 => [ 'ca', 'fl', 'ga', 'in', 'md', 'mt', 'ny', 'tx',
###                        'va', 'wc'
###                      ],
###              kjk4 => [ 'pa' ],
###              vdj2 => [ 'al', 'as', 'az', 'de', 'gu', 'la', 'ma', 'me',
###                        'mp', 'nh', 'nj', 'oh', 'ok', 'vi'
###                      ],
###            );
###
###
###my $findthis = 'tx';
###
###while ( (my $key, my $val) = each %stats ) {
###  for my $state ( @{$val} ) {
###    print "found -- $key owns $state\n" if $state eq $findthis;
###  }
###}
###
###
###print "\n";
###
###
###my @findthese = ('ar', 'tx');
###
#### Each element in hash
###while ( (my $key, my $val) = each %stats ) {
###  # Each element in hash's anon array
###  for my $state ( @{$val} ) {
###    # Each element in normal wanted array
###    for my $s ( @findthese ) {
###      # Compare what hash has with what we want
###      print "found -- $key owns $state\n" if $s eq $state;
###    }
###  }
###}



#########################
# More dynamic approach
#########################
# Assume INI:
# list=alm5,dwj2
# alm5=co,dc,hi
# dwj2=ca,fl,ga
# ...
# is turned into:
my @list = ('alm5', 'dwj2');
my %h = ();
my %found = ();
$h{alm5} = 'co, dc, hi';
$h{dwj2} = 'ca, fl, ga';

foreach my $person ( @list ) {
  $stats{$person} = [ split /\s*,\s*/, $h{$person} ];
}

# Now we have a partial:
#   %stats = ( alm5 => [ 'co', 'dc', 'hi', 'id', 'ks', 'mo', 'nc',
#                        'nm', 'or', 'ri', 'sd', 'tn', 'ut', 'vt',
#                        'wa', 'wi'
#                      ],
#              bxj9 => [ 'ak', 'ar', 'ct', 'ia', 'il', 'ky', 'mi', 'mn',
#                        'ms', 'nd', 'ne', 'nv', 'pr', 'sc', 'wv', 'wy'
#                      ],
#              ces0 => [ ],
#              dwj2 => [ 'ca', 'fl', 'ga', 'in', 'md', 'mt', 'ny', 'tx',
#                        'va', 'wc'
#                      ],
#              kjk4 => [ 'pa' ],
#              vdj2 => [ 'al', 'as', 'az', 'de', 'gu', 'la', 'ma', 'me',
#                        'mp', 'nh', 'nj', 'oh', 'ok', 'vi'
#                      ],
#            );
#
my $findthis2 = 'fl';

while ( (my $k, my $v) = each %stats ) {
  for my $state ( @{$v} ) {
    $found{$k}++ if $state eq $findthis2;
  }
}

if ( $found{dwj2} ) {
  print "dave has $findthis2\n";
}
