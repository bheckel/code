#!/usr/bin/env perl
##############################################################################
#     Name: config.pl
#
#  Summary: Check on Perl internal configuration.
#
#  Created: Thu 24 Jul 2003 10:14:03 (Bob Heckel)
# Modified: Fri 15 Apr 2005 23:57:52 (Bob Heckel)
##############################################################################
use strict;
use Config;

###while ( (my $k, my $v) = each %Config ) { print "$k=$v\n"; }

foreach my $k ( sort keys %Config ) {
  print "$k=$Config{$k}\n";
}
