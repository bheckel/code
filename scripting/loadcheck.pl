#!/usr/bin/perl -w
##############################################################################
#     Name: loadcheck.pl
#
#  Summary: Determine the load on the Unix box while a process is running.
#           
#           Customized for Debian (won't work on Cygwin). 
#
#  Created: Mon 16 Sep 2002 13:22:03 (Bob Heckel)
##############################################################################
use strict;

print AvgLoad();
# ...run something processor-intensive
print AvgLoad();

sub AvgLoad {
  # Sample line:
  # " 12:56pm  up 73 days, 31 min,  4 users,  load average: 0.11, 0.14, 0.16"
  my @foo = split /\s+/, `uptime`;
  my $numeric = $foo[11];
  $numeric =~ s/,//g;

  return $numeric;
}
